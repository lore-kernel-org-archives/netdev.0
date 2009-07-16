From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 0/7] IPsec: convert to ahash
Date: Thu, 16 Jul 2009 13:15:48 +0200
Message-ID: <20090716111548.GP20288@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset converts IPsec over to the new ahash interface.
The pachset applies to cryptodev-2.6. I was able to test the synchronous
codepaths, the asynchronous ones are untested.

I'm still somewhat unhappy with the ahash version of authenc, but I decided
to post anyway as a base for discussion.

Since the calls to the hash algorithms can now return asynchronous, I'd like
to avoid multiple calls to the hash update functions. I'd rather like to do
all the hashing with one call to crypto_ahash_digest(). As it is, this
requires chaining of all the involved scatterlists. Since we still can't use
sg_chain() to chain up the lists, I added an additional scatterlist entry to
the scatterlist of the assoc data (esp) to be able to chain later in the
crypto layer. To keep compatibility I set the termination bit at the first
entry and remove it later in authenc. In fact to rely on this additional
entry and just to remove the termintation bit later makes me a bit nervous
and I'm not sure whether this is acceptable, so better ideas are very welcome.

Steffen

