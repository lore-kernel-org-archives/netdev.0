From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: authenc compile warnings in current net-2.6.24
Date: Fri, 12 Oct 2007 08:15:01 +0200
Message-ID: <470F10E5.7090606@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:47695 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbXJLGPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 02:15:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

this compile fix seems not to be applied (maybe my compiler is the only 
one who complains ;-)

Acked-by: Oliver Hartkopp <oliver@hartkopp.net>

Thanks!


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
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

