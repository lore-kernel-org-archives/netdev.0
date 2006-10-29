From: Ray Lehtiniemi <rayl@mail.com>
Subject: Re: [PATCH 3/3] ep93xx_eth: don't report RX FIFO overrun errors
Date: Sun, 29 Oct 2006 11:15:28 -0700
Message-ID: <200610291115.29428.rayl@mail.com>
References: <20061029130649.GD6900@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shawidc-mo1.cg.shawcable.net ([24.71.223.10]:49972 "EHLO
	pd4mo1so.prod.shaw.ca") by vger.kernel.org with ESMTP
	id S932350AbWJ2SPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Oct 2006 13:15:36 -0500
Received: from pd4mr5so.prod.shaw.ca (pd4mr5so-qfe3.prod.shaw.ca [10.0.141.50])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0J7W00IX1TDY5740@l-daemon> for netdev@vger.kernel.org; Sun,
 29 Oct 2006 11:15:34 -0700 (MST)
Received: from pn2ml5so.prod.shaw.ca ([10.0.121.149])
 by pd4mr5so.prod.shaw.ca (Sun Java System Messaging Server 6.2-2.05 (built Apr
 28 2005)) with ESMTP id <0J7W0068KTDYVH80@pd4mr5so.prod.shaw.ca> for
 netdev@vger.kernel.org; Sun, 29 Oct 2006 11:15:34 -0700 (MST)
Received: from ray.lehtiniemi.com ([68.147.121.172])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0J7W00I7OTDY1RA4@l-daemon> for netdev@vger.kernel.org; Sun,
 29 Oct 2006 11:15:34 -0700 (MST)
In-reply-to: <20061029130649.GD6900@xi.wantstofly.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 29 October 2006 06:06, Lennert Buytenhek wrote:
> Flooding the console with an RX FIFO overrun error for every single
> dropped packet isn't very sensible.  The hardware is very underpowered
> according to today's standards, and RX FIFO overrun errors can be
> triggered quite easily, so don't report them at all.
>
> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
>
> Index: linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
> ===================================================================
> --- linux-2.6.19-rc3.orig/drivers/net/arm/ep93xx_eth.c
> +++ linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
> @@ -230,8 +230,9 @@ static int ep93xx_rx(struct net_device *
>  					 " %.8x %.8x\n", rstat0, rstat1);
>
>  		if (!(rstat0 & RSTAT0_RWE)) {
> -			printk(KERN_NOTICE "ep93xx_rx: receive error "
> -					 " %.8x %.8x\n", rstat0, rstat1);
> +			if (!(rstat0 & RSTAT_OE))
> +				printk(KERN_NOTICE "ep93xx_rx: receive error "
> +				       " %.8x %.8x\n", rstat0, rstat1);
>
>  			ep->stats.rx_errors++;
>  			if (rstat0 & RSTAT0_OE)


i got a compile error: please s/RSTAT_OE/RSTAT0_OE/ in this patch.  Also, is 
it possible for any other error bits to be set at the same time as OE?  such 
bits would not be printed to the log in this case.

ray
