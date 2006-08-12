From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_shared_info()
Date: Sat, 12 Aug 2006 10:32:15 +1000
Message-ID: <20060812003215.GB17238@gondor.apana.org.au>
References: <20060808.163915.03600382.davem@davemloft.net> <20060811140019.GA8611@ms2.inr.ac.ru> <20060811.172730.34542868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org, johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:13331 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932464AbWHLAcg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 20:32:36 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060811.172730.34542868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 11, 2006 at 05:27:30PM -0700, David Miller wrote:
> 
> E1000 wants 16K buffers for jumbo MTU settings.
> 
> The reason is that the chip can only handle power-of-2 buffer
> sizes, and next hop from 9K is 16K.
> 
> It is not possible to tell the chip to only accept 9K packets, you
> must give it the whole next power of 2 buffer size for the MTU you
> wish to use.
> 
> With skb_shared_info() overhead this becomes a 32K allocation
> in the simplest implementation.

I think is no longer an issue because we've all come to the conclusion
that E1000 supports SG and therefore we can and should use 4K pages, no?

Whatever we do here, allocating 16K via kmalloc is very unlikely to
succeed in the near future so we have to via the SG route anyway.
In which case that we must have a head area which can accomodate the
skb_shared_info as we do now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
