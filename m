From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/3] ep93xx_eth: don't report RX FIFO overrun errors
Date: Sun, 29 Oct 2006 19:22:53 +0100
Message-ID: <20061029182253.GE7055@xi.wantstofly.org>
References: <20061029130649.GD6900@xi.wantstofly.org> <200610291115.29428.rayl@mail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:10670 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932353AbWJ2SWz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Oct 2006 13:22:55 -0500
To: Ray Lehtiniemi <rayl@mail.com>
Content-Disposition: inline
In-Reply-To: <200610291115.29428.rayl@mail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 29, 2006 at 11:15:28AM -0700, Ray Lehtiniemi wrote:

> > Index: linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
> > ===================================================================
> > --- linux-2.6.19-rc3.orig/drivers/net/arm/ep93xx_eth.c
> > +++ linux-2.6.19-rc3/drivers/net/arm/ep93xx_eth.c
> > @@ -230,8 +230,9 @@ static int ep93xx_rx(struct net_device *
> >  					 " %.8x %.8x\n", rstat0, rstat1);
> >
> >  		if (!(rstat0 & RSTAT0_RWE)) {
> > -			printk(KERN_NOTICE "ep93xx_rx: receive error "
> > -					 " %.8x %.8x\n", rstat0, rstat1);
> > +			if (!(rstat0 & RSTAT_OE))
> > +				printk(KERN_NOTICE "ep93xx_rx: receive error "
> > +				       " %.8x %.8x\n", rstat0, rstat1);
> >
> >  			ep->stats.rx_errors++;
> >  			if (rstat0 & RSTAT0_OE)
> 
> i got a compile error: please s/RSTAT_OE/RSTAT0_OE/ in this patch.

Whoops, I thought I sent the right one.  :(


> Also, is it possible for any other error bits to be set at the same
> time as OE?  such bits would not be printed to the log in this case.

Not sure, but arguably, this wouldn't be very interesting.  Actually,
now I'm wondering whether we should just remove the printk altogether.


cheers,
Lennert
