From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] macb: Call phy_disconnect on removing
Date: Tue, 15 Apr 2008 01:53:31 -0700
Message-ID: <20080415015331.b6ab8963.akpm@linux-foundation.org>
References: <20080410.233007.41197293.anemo@mba.ocn.ne.jp>
	<48005E6E.3010802@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49210 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754239AbYDOIxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 04:53:44 -0400
In-Reply-To: <48005E6E.3010802@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Apr 2008 03:02:06 -0400 Jeff Garzik <jeff@garzik.org> wrote:

> Atsushi Nemoto wrote:
> > Call phy_disconnect() on remove routine.  Otherwise the phy timer
> > causes a kernel crash when unloading.
> > 
> > Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> > ---
> > diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> > index 1d210ed..10fcea5 100644
> > --- a/drivers/net/macb.c
> > +++ b/drivers/net/macb.c
> > @@ -1257,6 +1257,8 @@ static int __exit macb_remove(struct platform_device *pdev)
> >  
> >  	if (dev) {
> >  		bp = netdev_priv(dev);
> > +		if (bp->phy_dev)
> > +			phy_disconnect(bp->phy_dev);
> >  		mdiobus_unregister(&bp->mii_bus);
> >  		kfree(bp->mii_bus.irq);
> 
> applied
> 

Needed in 2.6.24.x as well, I think?
