From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/7] [IPSEC]: Lock state when copying non-atomic fields to user-space
Date: Mon, 26 Nov 2007 11:18:45 +0800
Message-ID: <20071126031845.GA23417@gondor.apana.org.au>
References: <20071009143517.GA20486@gondor.apana.org.au> <20071009.133307.88477317.davem@davemloft.net> <20071010004822.GB25265@gondor.apana.org.au> <200711261203.46195.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1603 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755379AbXKZDSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 22:18:52 -0500
Content-Disposition: inline
In-Reply-To: <200711261203.46195.nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 12:03:46PM +0900, Masahide NAKAMURA wrote:
>
> With SMP enabled kernel, I found a lock problem at xfrm_state_walk()
> path with the patch on current net-2.6.25. Its log is "circular locking
> dependency detected".

Thanks.  Ingo Molnar reported that too.

I'm just going to revert this patch for 2.6.24 since we've lived
with this race for so long anyway.

Later I'm going to change the locking order so that we always do
the xfrm_state_lock first before taking the x->lock. The rationale
is that only x->lock is taken on the fast path so we want minimise
its outage while xfrm_state_lock isn't.

In fact another change I want to do even later is to move the
expire timers into a work queue which would let us get rid of the
xfrm_*_lock's altogether.

Hmm, I've been talking about that second item for years :) Anybody
who wants to contribute to either of this is most welcome since
my plate's pretty full already.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
