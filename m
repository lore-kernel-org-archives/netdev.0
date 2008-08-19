From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 07:23:48 +0000
Message-ID: <20080819072348.GC4376@ff.dom.local>
References: <20080818.171124.192743795.davem@davemloft.net> <20080818.210701.80578862.davem@davemloft.net> <20080819064609.GA4376@ff.dom.local> <20080819.000307.71415459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:59868 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbYHSHXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 03:23:53 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1371552nfc.21
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 00:23:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080819.000307.71415459.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 12:03:07AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 19 Aug 2008 06:46:09 +0000
> 
> > Actually, I, and earlier Herbert, have written about destroying root
> > qdiscs without sch_tree_lock(). I don't know how Herbert, but I'd
> > prefer to leave here this lock for child qdiscs: they can remove some
> > common structures, so this needs more checking, and even if they don't
> > do this currently, there is no need to remove this possibility here.
> > Similarly, I'm not sure if removing BH protection is really needed
> > here.
> 
> Well you don't really know if this happens or not for sure
> do you? :-)

Actually, you are the author, and I'm here only to make some FUD...

> Why don't you go make sure of this and report back what you
> find?  I see no reason to account for something that cannot
> happen.

Sure, this can be done, but needs some time. And removing such old
locking could be treacherous, so I'd say otherwise, let's leave it
where we are not sure (and where it's not necessary) until more
checking. Currently I think mostly of something like cls_u32(). And
it's not the easiest to analyze piece of code.

> It's better to have a consistent rule for qdisc_destroy()
> rather than a bunch of special cases that are hard to audit.

I don't agree with this: there is a difference between doing total
destruction, when you are sure proper order doesn't matter, and
nobody will ever read after this.

Jarek P.
