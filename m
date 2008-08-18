From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 16:47:48 -0700 (PDT)
Message-ID: <20080818.164748.86676462.davem@davemloft.net>
References: <20080817.184921.08829673.davem@davemloft.net>
	<20080818212946.GB3366@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35944
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753390AbYHRXrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 19:47:49 -0400
In-Reply-To: <20080818212946.GB3366@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 Aug 2008 23:29:46 +0200

> Two little doubts below:
> 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 600bb23..b88f669 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -1341,6 +1341,9 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
> >  
> >  void __netif_schedule(struct Qdisc *q)
> >  {
> > +	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
> > +		return;
> > +
> 
> Why I can't see this code in net-2.6? BTW, I guess it should be now
> moved to the current __netif_reschedule()? 

I deleted it, it's unnecessary with your "both bits clear" fix
which I also added.

> OK, we now have this kfree_skb() with NET_XMIT_DROP here, but how is it
> better than qdisc_enque_root() on noop_qdisc? Or how can we have here
> anything else under both rcu lock and spin_lock() while this
> __QDISC_STATE_DEACTIVATED bit is set?

Both operations are equivalent, the choice is arbitrary in my
opinion.  It's not like the user can even see this in noop_qdisc's
stats or something like that.

