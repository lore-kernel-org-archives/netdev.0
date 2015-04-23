From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: CCM/GCM implementation defect
Date: Thu, 23 Apr 2015 11:26:20 +0800
Message-ID: <20150423032619.GA17648@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Wouters <pwouters@redhat.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

It looks like our IPsec implementations of CCM and GCM are buggy
in that they don't include the IV in the authentication calculation.

This definitely breaks interoperability with anyone who implements
them correctly.  The fact that there have been no reports on this
probably means that nobody has run into this in the field yet.

On the security side, this is probably not a big deal for CCM
because it always verifies the authentication tag after decryption.
But for GCM this may be a DoS issue as an attacker could modify
the IV without triggering the authentication check and thus cause
an unnecessary decryption.  For both CCM and GCM this will result
in random data injected as a packet into the network stack which
hopefully will be dropped.

In order to fix this without breaking backwards compatibility,
my plan is to introduce new templates such as rfc4106v2 which
implement the RFC correctly.  The existing templates will be
retained so that current users aren't broken by the fix.

Once the kernel side is complete we could then get the user-space
implementors to update their tools to request for the new v2
templates.

Comments?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
