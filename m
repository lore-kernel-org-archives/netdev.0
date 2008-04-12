From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] macb: Call phy_disconnect on removing
Date: Sat, 12 Apr 2008 03:02:06 -0400
Message-ID: <48005E6E.3010802@garzik.org>
References: <20080410.233007.41197293.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>, netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37706 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754399AbYDLHCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 03:02:11 -0400
In-Reply-To: <20080410.233007.41197293.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Atsushi Nemoto wrote:
> Call phy_disconnect() on remove routine.  Otherwise the phy timer
> causes a kernel crash when unloading.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> index 1d210ed..10fcea5 100644
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
> @@ -1257,6 +1257,8 @@ static int __exit macb_remove(struct platform_device *pdev)
>  
>  	if (dev) {
>  		bp = netdev_priv(dev);
> +		if (bp->phy_dev)
> +			phy_disconnect(bp->phy_dev);
>  		mdiobus_unregister(&bp->mii_bus);
>  		kfree(bp->mii_bus.irq);

applied


