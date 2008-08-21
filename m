From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 22:22:45 +1000
Message-ID: <20080821122245.GA8533@gondor.apana.org.au>
References: <20080821101830.GB3963@ff.dom.local> <20080821102153.GB3789@gondor.apana.org.au> <20080821102338.GA3864@gondor.apana.org.au> <20080821103354.GA4079@ff.dom.local> <20080821105110.GA4088@gondor.apana.org.au> <20080821112055.GB4079@ff.dom.local> <20080821112609.GA5052@gondor.apana.org.au> <20080821115521.GC4079@ff.dom.local> <20080821120112.GA7705@gondor.apana.org.au> <20080821121920.GD4079@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43098 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752250AbYHUMWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:22:51 -0400
Content-Disposition: inline
In-Reply-To: <20080821121920.GD4079@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 12:19:20PM +0000, Jarek Poplawski wrote:
> 
> Since qdisc_destroy() is used for destroying root qdisc too, isn't it
> better to get this lock back in notify_and_destroy() like this:
> 
> if (old) {
> 	if (parent)
> 		sch_tree_lock()
> 	qdisc_destroy()
> 	if (parent)
> 		sch_tree_unlock()
> }

Ugly as it may look, I think this is probably the best fix for now.

For 2.6.28 we can fix it properly and remove this eyesore :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
