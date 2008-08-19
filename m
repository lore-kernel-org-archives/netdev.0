From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 18:05:57 +1000
Message-ID: <20080819080557.GA17977@gondor.apana.org.au>
References: <20080818.165411.255925269.davem@davemloft.net> <20080819000551.GA26699@gondor.apana.org.au> <20080818.171124.192743795.davem@davemloft.net> <20080818.210701.80578862.davem@davemloft.net> <20080819064609.GA4376@ff.dom.local> <20080819072316.GA4878@gondor.apana.org.au> <20080819073558.GD4376@ff.dom.local> <20080819074606.GA5261@gondor.apana.org.au> <20080819075623.GE4376@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46458 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752633AbYHSIGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:06:03 -0400
Content-Disposition: inline
In-Reply-To: <20080819075623.GE4376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 07:56:23AM +0000, Jarek Poplawski wrote:
>
> I'm not sure I can understand you: could you look at htb_destroy()
> instead and think of this as a child qdisc of prio or another htb?
> Having a top level "queue" lock guarantees there is no activity at
> the whole tree at the moment.

htb_destroy can either be called by qdisc_destroy or when a brand
new HTB qdisc fails construction.  The latter case is trivial since
the qdisc has never been used.

In the first case, as you have seen from my previous email, the
entire branch containing the HTB qdisc (that is, either the HTB
qdisc itself if it's being deleted directly, or the branch stemming
from its ancestor that's being deleted) must no longer have any
references to it at all apart from this thread of execution.

As such we can do whatever we want with it, including freeing it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
