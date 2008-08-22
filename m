From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 22:45:57 +1000
Message-ID: <20080822124556.GA15788@gondor.apana.org.au>
References: <20080822.044248.175133807.davem@davemloft.net> <20080822120918.GB14981@ff.dom.local> <20080822121144.GA32397@gondor.apana.org.au> <20080822.051841.259820995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54719 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753430AbYHVMqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 08:46:11 -0400
Content-Disposition: inline
In-Reply-To: <20080822.051841.259820995.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 05:18:41AM -0700, David Miller wrote:
> 
> Netem is trying to create packet reordering by requeueing (which is
> logically like a head insert) instead of enqueueing (which is
> logically like a tail insert).

Why does it use requeue when tfifo's enqueue will insert this
at the front of the queue anyway based on time_to_send anyway?

Perhaps it's trying to force reordering when the user replaces
tfifo with some other qidsc? But that doesn't make sense since
netem relies on tfifo to implement all the other features such
as delay and jitter.

So how about

1) Change netem_graft to disallow the replacement of tfifo;
2) Simply use enqueue instead of requeue in netem_enqueue?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
