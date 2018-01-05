//
//  ViewController.m
//  CronetTest
//
//  Created by emilymmwang on 2018/1/3.
//  Copyright © 2018年 emilymmwang. All rights reserved.
//

#import "ViewController.h"
#include <Cronet/Cronet.h>


@interface ViewController () <CronetMetricsDelegate> {
    NSURLSessionConfiguration *_configuration;
    NSURLSession *_session;
    UIImageView *_imageViewQuic;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton new];
    [button setFrame:CGRectMake(100, 100, 200, 100)];
    [button setTitle:@"请求" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(startRequest) forControlEvents:UIControlEventTouchUpInside];
    
    _imageViewQuic = [[UIImageView alloc] initWithFrame:CGRectMake(40, 200, 100, 175)];
    _imageViewQuic.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_imageViewQuic];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)startRequest
{
    [Cronet initialize];
    [Cronet setRequestFilterBlock:^(NSURLRequest* request) {
        return YES;
    }];
    StartCronet(443);
    
    _configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    _configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    [Cronet registerHttpProtocolHandler];
    [Cronet installIntoSessionConfiguration:_configuration];
    
    _session = [NSURLSession sessionWithConfiguration:_configuration];
    
    NSURL *url = [NSURL URLWithString:@"https://vip.qzone.qq.com/proxy/domain/qzonestyle.gtimg.cn/qzone/space_item/boss_pic/2472_2017_11/1512034326193_704231.jpg"];
    NSURLSessionDataTask* task = [_session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIImage *image =  [UIImage imageWithData:data];
//                [_imageViewQuic setImage:image];
//            });
        }
    }];

    
    StartDataTaskAndWaitForCompletion(task);
}

void StartCronet(int port) {
//    [Cronet setUserAgent:@"CronetTest/1.0.0.0" partial:NO];
    [Cronet setQuicEnabled:true];
    [Cronet setHttp2Enabled:false];
    [Cronet setBrotliEnabled:false];
    [Cronet setAcceptLanguages:@"zh-CN,zh;q=0.9"];
//    [Cronet setExperimentalOptions:[NSString stringWithFormat:@"{\"ssl_key_log_file\":\"%@\"}", [Cronet getNetLogPathForFile:@"SSLKEYLOGFILE"]]];
    BOOL result = [Cronet addQuicHint:@"vip.qzone.qq.com" port:443 altPort:443];
    
    [Cronet enableTestCertVerifierForTesting];
    [Cronet setHttpCacheType:CRNHttpCacheTypeDisabled];
    [Cronet start];
    NSString* rules = [NSString stringWithFormat:@"MAP vip.qzone.qq.com vip.qzone.qq.com:%d",
                                                                 port];
    [Cronet setHostResolverRulesForTesting:rules];
}

void StartDataTaskAndWaitForCompletion(NSURLSessionDataTask* task) {
    [task resume];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)URLSession:(NSURLSession*)session task:(NSURLSessionTask*)task
didFinishCollectingMetrics:(NSURLSessionTaskMetrics*)metrics
{
    NSURLSessionTaskTransactionMetrics *metric = metrics.transactionMetrics.lastObject;
    NSLog(@"%zd",metric.isReusedConnection);
}

- (void)dealloc
{
    [Cronet initialize];
}


@end
