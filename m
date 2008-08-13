From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 10:50:52 +0000
Message-ID: <20080813105052.GA6838@ff.dom.local>
References: <20080813061317.GA4251@ff.dom.local> <20080812.231633.193696650.davem@davemloft.net> <20080813065302.GB4251@ff.dom.local> <20080813.022549.203848195.davem@davemloft.net> <20080813102701.GD5367@ff.dom.local> <20080813104238.GA11374@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:39988 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbYHMKvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 06:51:01 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1636734fgg.17
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 03:50:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080813104238.GA11374@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 08:42:38PM +1000, Herbert Xu wrote:
> On Wed, Aug 13, 2008 at 10:27:01AM +0000, Jarek Poplawski wrote:
> > 
> > - in net_tx_action() we can hit a place just after clear_bit() where
> > none of these bits is set. Of course, hitting this 2 times in a row
> > seems to be very unprobable, yet possible, and a lock isn't helpful
> > here, so probably some change around this would make this nicer.
> >
> > - isn't there possible some longer ping-pong between qdic_run() and
> > net_tx_action() when dev_requeue_skb() would get it back to
> > __netif_schedule() and so on (with NETDEV_TX_BUSY)?
> 
> Good point.  I think we should add an aliveness check in both
> net_tx_action and qdisc_run.  In fact the net_tx_action problem
> existed previously as well.  But it is pretty darn unlikely.

Yes, it seems qdisc_reset() doesn't have to help with this, so
probably there is needed some requeue counter or something...

Jarek P.
