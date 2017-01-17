//
//  DYNavigationController.m
//  GestureDemo
//
//  Created by Ethank on 16/4/29.
//  Copyright © 2016年 Ldy. All rights reserved.
//

#import "DYNavigationController.h"

@interface DYNavigationController ()
@property (nonatomic, strong)NSMutableArray *imgArray;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UIView *cover;
@property (nonatomic, assign)BOOL isLoadedImage;
@end


@implementation DYNavigationController

- (NSMutableArray *)imgArray {
    if (!_imgArray) {
        self.imgArray = [NSMutableArray array];
    }
    return _imgArray;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(-window.bounds.size.width, 0, window.bounds.size.width, window.bounds.size.height);
        self.imageView = imageView;
    }
    return _imageView;
}

- (UIView *)cover {
    if (!_cover) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIView *cover = [[UIView alloc] init];
        cover.frame = window.bounds;
        cover.backgroundColor =[UIColor blackColor];
        cover.alpha = 0.3;
        self.cover = cover;
    }
    return _cover;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage imageNamed:@"nav_bottom_line"]];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.imgArray.count > 0) return;
    [self createScreenShot];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    [self createScreenShot];
}

- (void)dragging:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (self.viewControllers.count <= 1) return;
    CGFloat translationX = [panGestureRecognizer translationInView:self.view].x;
    if (translationX <= 0) return;
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded || panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        self.isLoadedImage = NO;
        CGFloat x = self.view.frame.origin.x;
        if (x > self.view.frame.size.width * 0.5) {
            [UIView animateWithDuration:0.2 animations:^{
                self.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
                self.imageView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
            } completion:^(BOOL finished) {
                [self popViewControllerAnimated:NO];
                self.view.transform = CGAffineTransformIdentity;
                self.imageView.transform = CGAffineTransformIdentity;
                [self.imageView removeFromSuperview];
                [self.cover removeFromSuperview];
                [self.imgArray removeLastObject];
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                self.view.transform = CGAffineTransformIdentity;
                self.imageView.transform = CGAffineTransformIdentity;
            }];
        }
    } else {
        self.view.transform = CGAffineTransformMakeTranslation(translationX, 0);
        self.imageView.transform = CGAffineTransformMakeTranslation(translationX + 3, 0);//加3防止出现黑色边线
        if (!self.isLoadedImage) {//减少重复赋值
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            self.imageView.image = self.imgArray[self.imgArray.count - 2];
            [window insertSubview:self.imageView atIndex:0];
            [window insertSubview:self.cover aboveSubview:self.imageView];
            self.isLoadedImage = YES;
        }
    }
}
//生成截图
- (void)createScreenShot {
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self.imgArray addObject:image];
}
@end
