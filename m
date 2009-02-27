From: David Miller <davem@davemloft.net>
Subject: Re: Kernel problem
Date: Fri, 27 Feb 2009 01:16:15 -0800 (PST)
Message-ID: <20090227.011615.104197338.davem@davemloft.net>
References: <20090227084109.GA4156@ff.dom.local>
	<20090227.005907.94994126.davem@davemloft.net>
	<20090227091216.GB4156@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ash@sevsky.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752600AbZB0JQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 04:16:35 -0500
In-Reply-To: <20090227091216.GB4156@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 27 Feb 2009 09:12:16 +0000

> On Fri, Feb 27, 2009 at 12:59:07AM -0800, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Fri, 27 Feb 2009 08:41:10 +0000
> > 
> > > Probably I miss something, but I'm not sure it's really necessary in
> > > all (non-VLAN) entry points. Of course it's an optimization to drop
> > > these things early, but there is a lot off mess with replicating
> > > various parts of netif_receive_skb() in so many places.
> > > 
> > > As a matter of fact, I wonder why it can't be done in one place, e.g.
> > > netif_nit_deliver(), which was created partly for similar problems.
> > 
> > I think we do need to hit all possible entry points.
> > 
> > How would you be able to handle it in netif_nit_deliver()?
> > Functions like netif_receive_skb() open-code the delivery to
> > network taps, they don't actually call netif_receive_skb().
> 
> netif_nit_deliver() is a place called by vlan with orig skb->dev, so
> it could be reused to check for netpoll btw. Of course, return value
> should be added etc. and maybe name changed too. It could be
> something like this:

Note there is already a function that could do this and which needs to
hit all the same RX entrypoints just like this check would.

And that is skb_bond_should_drop().

We could rename that to skb_rx_should_drop() and put the netpoll
checks there.

There is some weird conditinalization of skb_bond_should_drop()'s call
in netif_receive_skb() but that should be easy to change to suit our
needs.  Perhaps by putting the calculation of the netdevice bonding
pointers into that function.
