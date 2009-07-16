From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH 0/7] IPsec: convert to ahash
Date: Thu, 16 Jul 2009 23:46:14 +0800
Message-ID: <20090716154614.GA4389@gondor.apana.org.au>
References: <20090716111548.GP20288@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090716111548.GP20288@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 16, 2009 at 01:15:48PM +0200, Steffen Klassert wrote:
>
> Since the calls to the hash algorithms can now return asynchronous, I'd like
> to avoid multiple calls to the hash update functions. I'd rather like to do
> all the hashing with one call to crypto_ahash_digest(). As it is, this
> requires chaining of all the involved scatterlists. Since we still can't use
> sg_chain() to chain up the lists, I added an additional scatterlist entry to
> the scatterlist of the assoc data (esp) to be able to chain later in the
> crypto layer. To keep compatibility I set the termination bit at the first
> entry and remove it later in authenc. In fact to rely on this additional
> entry and just to remove the termintation bit later makes me a bit nervous
> and I'm not sure whether this is acceptable, so better ideas are very welcome.

My suggestion would be to optimise for the common case, where
assoc is a single-entry list.  So just put some space aside in
the request context for a two-entry sg list and copy the assoc
sg entry into it and chain it with the rest.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
