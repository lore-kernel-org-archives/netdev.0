From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix xfrm hash collisions by changing
	__xfrm4_daddr_saddr_hash to hash addresses with addition
Date: Thu, 13 Aug 2009 12:06:06 +1000
Message-ID: <20090813020606.GA18205@gondor.apana.org.au>
References: <alpine.DEB.1.10.0908071032171.3426@sisapiiri.net.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jussi Maki <joamaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32958 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751060AbZHMCGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 22:06:11 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0908071032171.3426@sisapiiri.net.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Maki <joamaki@gmail.com> wrote:
>
> diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
> index d401dc8..e5195c9 100644
> --- a/net/xfrm/xfrm_hash.h
> +++ b/net/xfrm/xfrm_hash.h
> @@ -16,7 +16,7 @@ static inline unsigned int __xfrm6_addr_hash(xfrm_address_t *addr)
> 
> static inline unsigned int __xfrm4_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
> {
> -       return ntohl(daddr->a4 ^ saddr->a4);
> +       return ntohl(daddr->a4 + saddr->a4);
> }

What if the other side intentionally picks a destination addresses
to create collisions? Actually it's even easier than that.  We
don't include the SPI in the hash so regardless of how we hash
it, our peer can simply continue to create SAs with the same
descriptors and they'll all hash to the same bucket.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
