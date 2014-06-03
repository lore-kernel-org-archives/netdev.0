From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] gianfar: Call netif_carrier_off() prior to registration
Date: Tue, 3 Jun 2014 16:04:49 -0700
Message-ID: <CAGVrzcaK6n53=W+ixN9Hibc3oOgEGe7FFMVTwWzUNOyL3jotfw@mail.gmail.com>
References: <1401836138-13253-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	netdev <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:53303 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933973AbaFCXFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 19:05:30 -0400
Received: by mail-qg0-f44.google.com with SMTP id i50so14447347qgf.31
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 16:05:29 -0700 (PDT)
In-Reply-To: <1401836138-13253-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-03 15:55 GMT-07:00 Fabio Estevam <festevam@gmail.com>:
> From: Fabio Estevam <fabio.estevam@freescale.com>
>
> Quoting David Miller:
> "At the moment you call register_netdev() the device is visible, notifications
> are sent to userspace, and userland tools can try to bring the interface up
> and see the incorrect link state, before you do the netif_carrier_off().
>
> Said another way, between the register_netdev() and netif_carrier_off() call,
> userspace can see the device in an inconsistent state."
>
> So call netif_carrier_off() prior to register_netdev().

Potentially all drivers implementing libphy correctly should be fixed
to start with a carrier off until the phy library has determined
otherwise.

>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
> This is untested
>
>  drivers/net/ethernet/freescale/gianfar.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index a7fe6a7..861e0c9 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -1384,6 +1384,9 @@ static int gfar_probe(struct platform_device *ofdev)
>
>         gfar_hw_init(priv);
>
> +       /* Carrier starts down, phylib will bring it up */
> +       netif_carrier_off(dev);
> +
>         err = register_netdev(dev);
>
>         if (err) {
> @@ -1391,9 +1394,6 @@ static int gfar_probe(struct platform_device *ofdev)
>                 goto register_fail;
>         }
>
> -       /* Carrier starts down, phylib will bring it up */
> -       netif_carrier_off(dev);
> -
>         device_init_wakeup(&dev->dev,
>                            priv->device_flags &
>                            FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
> --
> 1.8.3.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
