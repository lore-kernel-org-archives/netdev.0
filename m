From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: Re: [PATCH] iSCSI fix endieness of digest to be network byte order
Date: Thu, 8 Nov 2007 18:40:40 +0800
Message-ID: <20071108104040.GA16312@gondor.apana.org.au>
References: <47320C54.10406@panasas.com> <20071108011849.GA12428@gondor.apana.org.au> <20071108170409B.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhalevy@panasas.com, linux-crypto@vger.kernel.org,
	michaelc@cs.wisc.edu, netdev@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071108170409B.fujita.tomonori@lab.ntt.co.jp>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 05:04:09PM +0900, FUJITA Tomonori wrote:
>
> I wonder why crc32c isn't used directly while crc32 is used directly
> since they vary by only the polynomial.

It's because iSCSI uses it with scatterlists.  The crypto layer
provides a nice interface for that while using it directly would
require the user to do the scatterlist walk.

> Using crc32c directly might enable us to kill net/sctp/crc32c.c and
> merge lib/crc32.c and lib/libcrc32c?

I'm pretty sure we can kill net/sctp/crc32c.c today by converting
it over to use the crypto interface.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
