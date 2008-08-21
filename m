From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 10:33:54 +0000
Message-ID: <20080821103354.GA4079@ff.dom.local>
References: <20080819085504.GB29038@gondor.apana.org.au> <20080819091642.GI4376@ff.dom.local> <20080821100155.GA3621@ff.dom.local> <20080821.030523.205239441.davem@davemloft.net> <20080821101145.GA3963@ff.dom.local> <20080821101830.GB3963@ff.dom.local> <20080821102153.GB3789@gondor.apana.org.au> <20080821102338.GA3864@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:4269 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172AbYHUKeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 06:34:01 -0400
Received: by ug-out-1314.google.com with SMTP id c2so996755ugf.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 03:33:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821102338.GA3864@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 08:23:38PM +1000, Herbert Xu wrote:
> On Thu, Aug 21, 2008 at 08:21:53PM +1000, Herbert Xu wrote:
> > On Thu, Aug 21, 2008 at 10:18:30AM +0000, Jarek Poplawski wrote:
> > >
> > > > > Remember, sch_tree_lock() uses qdisc_root_lock() which as I've
> > > > > told you at least twice now asserts that RTNL is held :-)
> > > > 
> > > > Actually, I've called it wrong, they hold qdisc root lock, but they
> > > > certainly can't have rtnl_lock() at the moment!
> > > 
> > > I mean here: hfsc_dequeue(), netem_dequeue() and tbf_dequeue().
> > 
> > Where do they use qdisc->list?
> 
> For the next development tree we could even add an ASSERT_RTNL to
> qdisc_lookup and co to ensure that nobody abuses this interface.

But if I get above right, you acknowledge the problem currently exists?

Jarek P.
