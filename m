From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.27-rc1]: fix NE2000 linkage error
Date: Wed, 30 Jul 2008 13:55:32 -0400
Message-ID: <4890AB14.1030009@garzik.org>
References: <200807301144.m6UBitOG022822@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34485 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758806AbYG3Rzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 13:55:43 -0400
In-Reply-To: <200807301144.m6UBitOG022822@harpo.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikael Pettersson wrote:
> Trying to build with CONFIG_NE2000=m fails with:
> 
>   scripts/mod/modpost   -o /tmp/tmp/linux-2.6.27-rc1/Module.symvers    -S     -s
> ERROR: "NS8390_init" [drivers/net/ne.ko] undefined!
> 
> This is because the split of 8390 into pausing and non-pausing
> versions was incompletely propagated to ne.c. This fixes it.
> 
> Signed-off-by: Mikael Pettersson <mikpe@it.uu.se>
> ---
> 
> --- linux-2.6.27-rc1/drivers/net/ne.c.~1~	2008-07-29 10:40:11.000000000 +0200
> +++ linux-2.6.27-rc1/drivers/net/ne.c	2008-07-30 13:17:16.000000000 +0200
> @@ -536,7 +536,7 @@ static int __init ne_probe1(struct net_d
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	dev->poll_controller = eip_poll;
>  #endif
> -	NS8390_init(dev, 0);
> +	NS8390p_init(dev, 0);
>  
>  	ret = register_netdev(dev);
>  	if (ret)
> @@ -794,7 +794,7 @@ retry:
>  		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
>  			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
>  			ne_reset_8390(dev);
> -			NS8390_init(dev,1);
> +			NS8390p_init(dev, 1);
>  			break;
>  		}
>  
> @@ -855,7 +855,7 @@ static int ne_drv_resume(struct platform
>  
>  	if (netif_running(dev)) {
>  		ne_reset_8390(dev);
> -		NS8390_init(dev, 1);
> +		NS8390p_init(dev, 1);
>  		netif_device_attach(dev);

Yep, already got this one, but thanks!


