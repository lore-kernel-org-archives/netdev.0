From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 10:25:54 +1100
Message-ID: <20081217232553.GA28582@gondor.apana.org.au>
References: <20081217114138.GA20976@gondor.apana.org.au> <20081217125505.GA8379@ms2.inr.ac.ru> <20081217221637.GA27811@gondor.apana.org.au> <20081217.151713.90960645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, ptesarik@suse.cz, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46240 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751892AbYLQX0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 18:26:11 -0500
Content-Disposition: inline
In-Reply-To: <20081217.151713.90960645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 03:17:13PM -0800, David Miller wrote:
> 
> Also, what if we're using IPV6 jumbo frames and we advertise this
> special 0xffff URG offset turd?  That points to a real byte in the
> packet, but it might not be the right one since we can only accurately
> point up to 0xffff into there.

1) We don't support that right now.

2) Even if we did this would be broken either way because just
where do you put the urgent pointer if your packet is > 64K and
the urgent pointer lies in the packet but beyond 64K to the start?

In any case we can easily fix this up with an additional check
so I don't think it's central to the issue overall.

> Given all of this I still think our current compromise is likely the
> best one.  We never will advertise an URG pointer that is not pointing
> to where the URG data will be in the sequence space.

I agree to the extent that urgent mode is hopelessly broken in
so many ways so one more isn't going to make that much of a
difference.

However, I still think that the approach suggested by Alexey is
better than the status quo:

1) It's unlikely to break any existing apps (all it does is send SIGURG
multiple times).

2) For those apps that use urgent mode in the first place, they're
likely to want to see the urgent notification ASAP, rather than having
it delayed due to the receiver being busy.  So this is an improvement
over what we have.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
