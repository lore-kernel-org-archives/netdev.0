From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD
 interface
Date: Sun, 24 May 2015 11:34:20 +0800
Message-ID: <20150524033420.GC20656@gondor.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
 <E1YviMC-00010E-Uk@gondolin.me.apana.org.au>
 <1969904.xZlo35YxmK@tachyon.chronox.de>
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
In-Reply-To: <1969904.xZlo35YxmK@tachyon.chronox.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 23, 2015 at 08:04:19PM +0200, Stephan Mueller wrote:
> Am Freitag, 22. Mai 2015, 16:31:04 schrieb Herbert Xu:
> 
> Hi Herbert,
> 
> > This patch makes use of the new AEAD interface which uses a single
> > SG list instead of separate lists for the AD and plain text.
> 
> After applying your additional patch, the "normal" AEAD operation works.
> 
> But with long messages (16 filled pages), I get the following. To test, simply 
> use [1], cd libkcapi/test, compile and execute ./kcapi -y

Thanks for testing!

Does this patch help?

diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
index a483a6f..1d08483 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -494,11 +494,11 @@ static int aead_recvmsg(struct socket *sock, struct msghdr *msg, size_t ignored,
 	else if (outlen)
 		/* AD size is non-zero */
 		scatterwalk_crypto_chain(
-			dst, ctx->rsgl[0].sg,
+			dst + i - 1, ctx->rsgl[0].sg,
 			sg_page(ctx->rsgl[0].sg) == sg_page(dst + i - 1) &&
 			ctx->rsgl[0].sg[0].offset == dst[i - 1].offset +
 						     dst[i - 1].length,
-			i + 1);
+			2);
 	else
 		/* AD only */
 		sg_mark_end(dst + i);

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
