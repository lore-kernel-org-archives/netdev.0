From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: authenc compile warnings in current net-2.6.24
Date: Thu, 11 Oct 2007 11:26:11 +0800
Message-ID: <20071011032611.GA14240@gondor.apana.org.au>
References: <470D11B1.2040207@hartkopp.net> <20071010195337.GA21597@Chamillionaire.breakpoint.cc> <20071010.162528.91758998.davem@davemloft.net> <20071011032330.GA14165@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@ml.breakpoint.cc, socketcan@hartkopp.net,
	netdev@vger.kernel.org,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071011032330.GA14165@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2007 at 11:23:30AM +0800, Herbert Xu wrote:
>
> Yeah I've added a fix in the cryptodev tree.

Oh and here's the actual patch.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
1cd6038ce42447f9a32e6d138af0b69ad56ea627
diff --git a/crypto/authenc.c b/crypto/authenc.c
index 0b29a6a..126a529 100644
--- a/crypto/authenc.c
+++ b/crypto/authenc.c
@@ -84,8 +84,8 @@ static int crypto_authenc_hash(struct aead_request *req)
 		.tfm = auth,
 	};
 	u8 *hash = aead_request_ctx(req);
-	struct scatterlist *dst;
-	unsigned int cryptlen;
+	struct scatterlist *dst = req->dst;
+	unsigned int cryptlen = req->cryptlen;
 	int err;
 
 	hash = (u8 *)ALIGN((unsigned long)hash + crypto_hash_alignmask(auth), 
@@ -100,8 +100,6 @@ static int crypto_authenc_hash(struct aead_request *req)
 	if (err)
 		goto auth_unlock;
 
-	cryptlen = req->cryptlen;
-	dst = req->dst;
 	err = crypto_hash_update(&desc, dst, cryptlen);
 	if (err)
 		goto auth_unlock;
@@ -159,8 +157,8 @@ static int crypto_authenc_verify(struct aead_request *req)
 	};
 	u8 *ohash = aead_request_ctx(req);
 	u8 *ihash;
-	struct scatterlist *src;
-	unsigned int cryptlen;
+	struct scatterlist *src = req->src;
+	unsigned int cryptlen = req->cryptlen;
 	unsigned int authsize;
 	int err;
 
@@ -177,8 +175,6 @@ static int crypto_authenc_verify(struct aead_request *req)
 	if (err)
 		goto auth_unlock;
 
-	cryptlen = req->cryptlen;
-	src = req->src;
 	err = crypto_hash_update(&desc, src, cryptlen);
 	if (err)
 		goto auth_unlock;
