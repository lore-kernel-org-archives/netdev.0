From: Yaroslav Isakov <yaroslav.isakov@gmail.com>
Subject: Re: [PATCH] tun: fix inability to set offloads after disabling them
 via ethtool
Date: Thu, 16 Mar 2017 22:42:18 +0300
Message-ID: <CADS+iDWhMQRRNke576R0x4h9Qrg+YDbUm4VE8bjsbG24_rtNDA@mail.gmail.com>
References: <58cae999.1b582e0a.a78bb.68f6@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34636 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751954AbdCPTnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 15:43:03 -0400
Received: by mail-wm0-f66.google.com with SMTP id u132so62705wmg.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 12:42:40 -0700 (PDT)
In-Reply-To: <58cae999.1b582e0a.a78bb.68f6@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for spamming mailing list, forgot to check via checkpatch.pl,
will resend it one more time

2017-03-16 21:08 GMT+03:00 Yaroslav Isakov <yaroslav.isakov@gmail.com>:
> Added missing logic in tun driver, which prevents apps to set
> offloads using tun ioctl, if offloads were previously disabled via ethtool
>
> Signed-of-by: Yaroslav Isakov (yaroslav.isakov@gmail.com)
> ---
>  drivers/net/tun.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 34cc3c5..cc88cd7 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1931,6 +1931,8 @@ static int set_offload(struct tun_struct *tun, unsigned long arg)
>                 return -EINVAL;
>
>         tun->set_features = features;
> +       tun->dev->wanted_features &= ~TUN_USER_FEATURES;
> +       tun->dev->wanted_features |= features;
>         netdev_update_features(tun->dev);
>
>         return 0;
> --
> 2.10.2
>
