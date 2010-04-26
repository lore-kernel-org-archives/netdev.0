From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GRO after RPS?
Date: Mon, 26 Apr 2010 09:47:44 +0800
Message-ID: <20100426014744.GA20093@gondor.apana.org.au>
References: <20100425.170933.190068177.davem@davemloft.net> <20100426004934.GA12525@gondor.apana.org.au> <20100425.181757.10149105.davem@davemloft.net> <m2q412e6f7f1004251840vdf264f38vd0df335802cb2a91@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:47759 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752808Ab0DZBrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 21:47:52 -0400
Content-Disposition: inline
In-Reply-To: <m2q412e6f7f1004251840vdf264f38vd0df335802cb2a91@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 26, 2010 at 09:40:35AM +0800, Changli Gao wrote:
> On Mon, Apr 26, 2010 at 9:17 AM, David Miller <davem@davemloft.net> wrote:
> >
> > The goal is to eliminate all packet header references from the pre-RPS
> > path, and let the post-RPS cpu do it.
> 
> If the NIC doesn't provide rxhash, RPS will have to compute one by one
> by itself. Is the hash computation more expensive than GRO? I think
> the hash computation is cheaper than GRO, so we can do RPS ASAP to
> avoid the direct CPU overload.

The dominating cost will be pulling the memory into cache.  So
once you do that the cost of GRO will be negligible.

As I said, if we had hardware rxhashes, we can change GRO to only
pull in the header when we're likely to have a match.

When we do get a mergeable flow, the difference between doing
GRO before/after RPS is going to be redirecting 1 packet vs.
~100 packets.

So if RPS is so cheap that it's able to process 100 packets at
a cost tantamount to 1 packet, then sure we should postpone GRO.

Otherwise I think GRO before RPS is definitely a win.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
