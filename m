From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Fri, 25 Jul 2008 12:08:49 +0000
Message-ID: <20080725120849.GA25369@ff.dom.local>
References: <20080725.035712.33516738.davem@davemloft.net> <20080725113757.GC10399@ff.dom.local> <20080725115355.GD10399@ff.dom.local> <20080725.045215.10253476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.181]:30064 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbYGYMDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 08:03:42 -0400
Received: by ik-out-1112.google.com with SMTP id c28so2656834ika.5
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 05:03:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080725.045215.10253476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 04:52:15AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 25 Jul 2008 11:53:55 +0000
> 
> > On Fri, Jul 25, 2008 at 11:37:57AM +0000, Jarek Poplawski wrote:
> >
> > As a matter of fact it's a good example: in your patch we have this:
> > 
> > +		ret = cl->un.leaf.q->enqueue(skb, cl->un.leaf.q);
> > +		if (ret == NET_XMIT_DROP) {
> > +			sch->qstats.drops++;
> > +			cl->qstats.drops++;
> > +		} else {
> > +			cl->bstats.packets +=
> > +				skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
> > +			cl->bstats.bytes += skb->len;
> > 
> > So, if something works like noop_enqueue() and returns NET_XMIT_CN
> > here, we're just using skb after kfree...
> 
> noop_enqueue() can only be a root qdisc, never a leaf hanging off of a
> class

OK, sfq does the same.

> What TCP depends upon is that DROP means DROP, and that the
> packet never reached the device and has been freed.

IMHO, TCP should depend on it's skb "refcount". A qdisc, after
passing skb to other qdisc shouldn't depend on TCP's "refcount"
because not everything has to work like TCP.

Jarek P.
