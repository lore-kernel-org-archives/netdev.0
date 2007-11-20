From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 09/11] netpoll: ethernet devices only
Date: Mon, 19 Nov 2007 20:14:59 -0800
Message-ID: <20071119201459.03d8f143@freepuppy.rosehill>
References: <20071103184314.216145305@linux-foundation.org>
	<20071103184338.929307786@linux-foundation.org>
	<20071119.195515.54073365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53870 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754113AbXKTEPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 23:15:15 -0500
In-Reply-To: <20071119.195515.54073365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Nov 2007 19:55:15 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Sat, 03 Nov 2007 11:43:23 -0700
> 
> > Netpoll only works on Ethernet devices, so check during setup
> > rather than just failing silently later.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> > 
> > --- a/net/core/netpoll.c	2007-11-03 11:05:33.000000000 -0700
> > +++ b/net/core/netpoll.c	2007-11-03 11:08:23.000000000 -0700
> > @@ -653,6 +653,12 @@ int netpoll_setup(struct netpoll *np, st
> >  	unsigned long flags;
> >  	int err;
> >  
> > +	if (ndev->type != ARPHRD_ETHER) {
> > +		printk(KERN_ERR "netpoll: %s is not an ethernet device\n",
> > +		       ndev->name);
> > +		return -EINVAL;
> > +	}
> > +
> >  	np->dev = ndev;
> 
> This patch depends upon the broken np->dev_name one, and I also would
> rather fix the limitations in netpoll.

Existing netpoll depends on Ethernet and IPV4. Doing the right thing
might be hard because it would mean going through more inside irq.

Probably the right thing to do would be to build a header through the
normal path and cache it some how.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
