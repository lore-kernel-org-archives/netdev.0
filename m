From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: systemport: Use devm_ioremap_resource()
Date: Tue, 13 May 2014 21:05:21 -0700
Message-ID: <CAGVrzcb5M-jZgZJnLKA8gzdnEV52aKtmuj1O9r5EbbOp=xuBmQ@mail.gmail.com>
References: <001c01cf6f22$c9fe6f60$5dfb4e20$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:46619 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbaENEGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 00:06:02 -0400
Received: by mail-qg0-f50.google.com with SMTP id z60so1949848qgd.9
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 21:06:01 -0700 (PDT)
In-Reply-To: <001c01cf6f22$c9fe6f60$5dfb4e20$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-13 20:15 GMT-07:00 Jingoo Han <jg1.han@samsung.com>:
> Use devm_ioremap_resource() because devm_request_and_ioremap() is
> obsoleted by devm_ioremap_resource().

As of net-next of today, I see nothing that warns when using this
function that it is obsolete, nor is it commented as such, how about
it gets annotated with __deprecated so people stop using it even for
new submissions?

>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index 4dc8d1e..1fa5205 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -1514,10 +1514,9 @@ static int bcm_sysport_probe(struct platform_device *pdev)
>                 goto err;
>         }
>
> -       priv->base = devm_request_and_ioremap(&pdev->dev, r);
> -       if (!priv->base) {
> -               dev_err(&pdev->dev, "register remap failed\n");
> -               ret = -ENOMEM;
> +       priv->base = devm_ioremap_resource(&pdev->dev, r);
> +       if (IS_ERR(priv->base)) {
> +               ret = PTR_ERR(priv->base);
>                 goto err;
>         }
>
> --
> 1.7.10.4
>
>



-- 
Florian
