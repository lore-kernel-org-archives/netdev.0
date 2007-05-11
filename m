From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] make qdisc_restart more readable
Date: Fri, 11 May 2007 14:11:44 -0400
Message-ID: <1178907104.4126.10.camel@localhost>
References: <1178842400.5008.17.camel@localhost>
	 <20070511170126.GH521@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:34016 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173AbXEKSLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 14:11:46 -0400
Received: by wx-out-0506.google.com with SMTP id h31so952576wxd
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 11:11:46 -0700 (PDT)
In-Reply-To: <20070511170126.GH521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-11-05 at 19:01 +0200, Thomas Graf wrote:
> * jamal <j.hadi123@gmail.com> 2007-05-10 20:13

> >   *	Compute the worst case header length according to the protocols
> > diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> > index f28bb2d..b821040 100644
> > --- a/net/sched/sch_generic.c
> > +++ b/net/sched/sch_generic.c
> > @@ -59,7 +59,79 @@ void qdisc_unlock_tree(struct net_device *dev)
> >  	spin_unlock_bh(&dev->queue_lock);
> >  }
> >  
> > -/*
> > +static inline int qqlen(struct Qdisc *q)
> > +{
> > +	BUG_ON((int) q->q.qlen < 0);
> > +	return q->q.qlen;
> > +}
> 
> Nitpicking but qdisc_qlen() sounds a lot better to me.
> 

I thought nitpicking was my department ;->
qdisc_qlen is more descriptive; i will change it.


> > +static inline int
> > +handle_dev_requeue(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
> > +{
> > +
> > +	if (unlikely(q == &noop_qdisc))
> > +		kfree_skb(skb);
> > +
> > +	if (skb->next)
> 
> Oops, missing else here, this will crash.
> 

tabarnaq. I will fix - thanks.

> Seems simpler to just return the skb or NULL instead
> 

sure.

> > +	/* churn baby churn .. */
> > +	ret = dev_hard_start_xmit(skb, dev);
> 
> Check whether queue is stopped got lost here
> 

Also caught by Peter - will fix.




> > +	q = dev->qdisc;
> 
> Maybe comment why q needs to be refreshed so nobody removes
> it by accident.

Makes sense ..

> > +	/* most likely result, packet went ok */
> > +	if (ret == NETDEV_TX_OK)
> > +		return qqlen(q);
> > +	/* only for lockless drivers .. */
> > +	if (ret == NETDEV_TX_LOCKED && lockless) {
> > +		return handle_tx_locked(skb, dev, q);
> > +	}
> 
> Your style of placing parentheses seems to vary randomly :-)

There may have been a debug in there that i removed. Frankly
i dont mind having braces even for a one liner, but i know that is not
popular with many folks.
Any other spot you noticed?

Thanks a lot Thomas.

cheers,
jamal

