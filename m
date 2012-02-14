From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: bonding with 3c59x driver
Date: Tue, 14 Feb 2012 14:34:18 +0100
Message-ID: <20120214133418.GJ32155@v3-1054>
References: <201202132253.16496.jdelvare@suse.de>
 <20120214110604.GI32155@v3-1054>
 <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <201202141350.57657.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slnx.de ([79.140.41.54]:58861 "EHLO v3-1054.slnx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756554Ab2BNNbx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 08:31:53 -0500
Content-Disposition: inline
In-Reply-To: <201202141350.57657.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2012 at 01:50:57PM +0100, Jean Delvare wrote:
> 
> > We could have a 5 sec timer in case device is a slave.
> > 
> > diff --git a/drivers/net/ethernet/3com/3c59x.c
> >  b/drivers/net/ethernet/3com/3c59x.c index 1282f04..e463d10 100644
> > --- a/drivers/net/ethernet/3com/3c59x.c
> > +++ b/drivers/net/ethernet/3com/3c59x.c
> > @@ -1841,7 +1841,7 @@ vortex_timer(unsigned long data)
> >  		ok = 1;
> >  	}
> > 
> > -	if (!netif_carrier_ok(dev))
> > +	if (dev->flags & IFF_SLAVE || !netif_carrier_ok(dev))
> >  		next_tick = 5*HZ;
> > 
> >  	if (vp->medialock)
> 
> Yes I think this makes a lot of sense. If you send this upstream you can 
> add:
> 
> Acked-by: Jean Delvare <jdelvare@suse.de>
> 

I'm fine with this too.
