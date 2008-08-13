From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 15:19:18 -0700 (PDT)
Message-ID: <20080813.151918.61294677.davem@davemloft.net>
References: <20080813102701.GD5367@ff.dom.local>
	<20080813104238.GA11374@gondor.apana.org.au>
	<20080813105052.GA6838@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54174
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756080AbYHMWTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 18:19:19 -0400
In-Reply-To: <20080813105052.GA6838@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 13 Aug 2008 10:50:52 +0000

> On Wed, Aug 13, 2008 at 08:42:38PM +1000, Herbert Xu wrote:
> > On Wed, Aug 13, 2008 at 10:27:01AM +0000, Jarek Poplawski wrote:
> > > 
> > > - in net_tx_action() we can hit a place just after clear_bit() where
> > > none of these bits is set. Of course, hitting this 2 times in a row
> > > seems to be very unprobable, yet possible, and a lock isn't helpful
> > > here, so probably some change around this would make this nicer.
> > >
> > > - isn't there possible some longer ping-pong between qdic_run() and
> > > net_tx_action() when dev_requeue_skb() would get it back to
> > > __netif_schedule() and so on (with NETDEV_TX_BUSY)?
> > 
> > Good point.  I think we should add an aliveness check in both
> > net_tx_action and qdisc_run.  In fact the net_tx_action problem
> > existed previously as well.  But it is pretty darn unlikely.
> 
> Yes, it seems qdisc_reset() doesn't have to help with this, so
> probably there is needed some requeue counter or something...

Ok, so what I'm going to do is check in my patch and then try
to figure out how to resolve this "both bits clear" scenerio.

Thanks.
