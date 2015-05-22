From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/2] crypto: Use tmpl->create when registering geniv
Date: Sat, 23 May 2015 05:54:31 +0800
Message-ID: <20150522215430.GA11512@gondor.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
 <E1YviMC-00010E-Uk@gondolin.me.apana.org.au>
 <1711949.C5mmxUsD4a@myon.chronox.de>
 <13023896.hEcYqcIc2j@myon.chronox.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <13023896.hEcYqcIc2j@myon.chronox.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 22, 2015 at 11:04:39PM +0200, Stephan Mueller wrote:
> Am Freitag, 22. Mai 2015, 22:59:34 schrieb Stephan Mueller:
> 
> Hi Stephan,
> 
> > Am Freitag, 22. Mai 2015, 16:31:04 schrieb Herbert Xu:
> > 
> > Hi Herbert,
> > 
> > > This patch makes use of the new AEAD interface which uses a single
> > > SG list instead of separate lists for the AD and plain text.
> > 
> > Using an up-to date tree with the full set of patches of this patch set, I
> > get the following oops.
> > 
> > It can easily be reproduced by using [1]: go to libkcapi/test/ and compile
> > with make. Then execute ./test.sh
> > 
> > [1] http://www.chronox.de/libkcapi.html
> 
> Note, gcm(aes) looks good. Only rfc4106(gcm(aes)) causes the crash.

Thanks for the report!

The crash is because ablkcipher/aead are still using tmpl->alloc
and I forgot about them.

The following two patches will fix the crash by making them call
tmpl->create if it is set.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
