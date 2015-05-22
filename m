From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 4/13] crypto: aead - Do not set cra_type for new style instances
Date: Fri, 22 May 2015 16:30:52 +0800
Message-ID: <E1YviM0-0000xd-D7@gondolin.me.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function aead_geniv_alloc currently sets cra_type even for
new style instances.  This is unnecessary and may hide bugs such
as when our caller uses crypto_register_instance instead of the
correct aead_register_instance.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/aead.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/crypto/aead.c b/crypto/aead.c
index c1f73a9..8b26613 100644
--- a/crypto/aead.c
+++ b/crypto/aead.c
@@ -468,12 +468,10 @@ struct aead_instance *aead_geniv_alloc(struct crypto_template *tmpl,
 	    CRYPTO_MAX_ALG_NAME)
 		goto err_drop_alg;
 
-	inst->alg.base.cra_flags = CRYPTO_ALG_TYPE_AEAD;
-	inst->alg.base.cra_flags |= alg->base.cra_flags & CRYPTO_ALG_ASYNC;
+	inst->alg.base.cra_flags = alg->base.cra_flags & CRYPTO_ALG_ASYNC;
 	inst->alg.base.cra_priority = alg->base.cra_priority;
 	inst->alg.base.cra_blocksize = alg->base.cra_blocksize;
 	inst->alg.base.cra_alignmask = alg->base.cra_alignmask;
-	inst->alg.base.cra_type = &crypto_new_aead_type;
 
 	inst->alg.ivsize = ivsize;
 	inst->alg.maxauthsize = maxauthsize;
