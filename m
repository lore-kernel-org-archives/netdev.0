From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 08:17:13 +0000
Message-ID: <20080819081713.GF4376@ff.dom.local>
References: <20080818.165411.255925269.davem@davemloft.net> <20080819000551.GA26699@gondor.apana.org.au> <20080818.171124.192743795.davem@davemloft.net> <20080818.210701.80578862.davem@davemloft.net> <20080819064609.GA4376@ff.dom.local> <20080819072316.GA4878@gondor.apana.org.au> <20080819073558.GD4376@ff.dom.local> <20080819074606.GA5261@gondor.apana.org.au> <20080819075623.GE4376@ff.dom.local> <20080819080557.GA17977@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:46138 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235AbYHSIRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:17:19 -0400
Received: by ug-out-1314.google.com with SMTP id c2so416114ugf.37
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 01:17:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080819080557.GA17977@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 06:05:57PM +1000, Herbert Xu wrote:
> On Tue, Aug 19, 2008 at 07:56:23AM +0000, Jarek Poplawski wrote:
> >
> > I'm not sure I can understand you: could you look at htb_destroy()
> > instead and think of this as a child qdisc of prio or another htb?
> > Having a top level "queue" lock guarantees there is no activity at
> > the whole tree at the moment.
> 
> htb_destroy can either be called by qdisc_destroy or when a brand
> new HTB qdisc fails construction.  The latter case is trivial since
> the qdisc has never been used.
> 
> In the first case, as you have seen from my previous email, the
> entire branch containing the HTB qdisc (that is, either the HTB
> qdisc itself if it's being deleted directly, or the branch stemming
> from its ancestor that's being deleted) must no longer have any
> references to it at all apart from this thread of execution.
> 
> As such we can do whatever we want with it, including freeing it.
> 

As I've written before I'm mainly concerned with things like
tcf_destroy_chain(), especially wrt. cls_u32, but I can be wrong with
this. So, if you don't have such concerns, let's forget it for now,
and after I look at this more maybe we'll get back to this discussion.

Jarek P.
