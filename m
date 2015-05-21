From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/7] crypto: Convert all AEAD users to new interface
Date: Thu, 21 May 2015 18:39:39 +0800
Message-ID: <20150521103938.GA23035@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

This series of patches convert all in-tree AEAD users that I
could find to the new single SG list interface.  For IPsec it
also adopts the new explicit IV generator scheme.

To recap, the old AEAD interface takes an associated data (AD)
SG list in addition to the plain/cipher text SG list(s).  That
forces the underlying AEAD algorithm implementors to try to stitch
those two lists together where possible in order to maximise the
contiguous chunk of memory passed to the ICV/hash function.  Things
get even more hairy for IPsec as it has a third piece of memory,
the generated IV (giv) that needs to be hashed.  One look at the
nasty things authenc does for example is enough to make anyone
puke :)

In fact the interface is just getting in our way because for the
main user IPsec the data is naturally contiguous as the protocol
was designed with this in mind.

So the new AEAD interface gets rid of the separate AD SG list
and instead simply requires the AD to be at the head of the src
and dst SG lists.  There is further provision for optional space
between the AD and the plain/cipher text for ease of implementation.

The conversion of in-tree users is fairly straightforward.  The
only non-trivial bit is IPsec as I'm taking this opportunity to
move the IV generation knowledge into IPsec as that's where it
belongs since we may in future wish to support different generation
schemes for a single algorithm.

As this depends on patches that have not hit mainline yet please
do not apply them.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
