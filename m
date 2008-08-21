From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 05:27:54 -0700 (PDT)
Message-ID: <20080821.052754.104318066.davem@davemloft.net>
References: <20080821120112.GA7705@gondor.apana.org.au>
	<20080821121920.GD4079@ff.dom.local>
	<20080821122245.GA8533@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37386
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751797AbYHUM1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:27:54 -0400
In-Reply-To: <20080821122245.GA8533@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 21 Aug 2008 22:22:45 +1000

> On Thu, Aug 21, 2008 at 12:19:20PM +0000, Jarek Poplawski wrote:
> > 
> > Since qdisc_destroy() is used for destroying root qdisc too, isn't it
> > better to get this lock back in notify_and_destroy() like this:
> > 
> > if (old) {
> > 	if (parent)
> > 		sch_tree_lock()
> > 	qdisc_destroy()
> > 	if (parent)
> > 		sch_tree_unlock()
> > }
> 
> Ugly as it may look, I think this is probably the best fix for now.
> 
> For 2.6.28 we can fix it properly and remove this eyesore :)

This looks even worse, actually.

If we just unlinked this thing, we don't want anyone finding
it, even before we grab this lock, to adjust queue counts.
