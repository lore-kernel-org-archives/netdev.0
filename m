From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 21:42:54 +1100
Message-ID: <20081217104254.GA17407@gondor.apana.org.au>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ptesarik@suse.cz
To: Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49324 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759355AbYLQKm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 05:42:59 -0500
Content-Disposition: inline
In-Reply-To: <20081217103129.GA17248@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 09:31:29PM +1100, Herbert Xu wrote:
>
> Oh I see what you mean now.  Yes this isn't as easy as it appears.

Reading RFC 793 again, it seems that what we're doing may not be
correct.  It would appear that the intention is to flag urgent mode
as soon as urgent data appears from the user, regardless of whether
it's 64K or more beyond the current sequence number.

The fact that the pointer is 16 bits long is not an issue.  We
should setting it to 0xffff.

The way we do it currently means that if there is loads of data
in the pipe then we don't signal urgent mode at all until we're
within 64K of snd.up, which defeats the whole point of urgent
mode.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
