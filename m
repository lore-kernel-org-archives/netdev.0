From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 30/51] crypto: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:20 -0400
Message-ID: <1333335521-1348-31-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292Ab2DBC77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:59 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 crypto/ablkcipher.c  |   12 ++++++------
 crypto/aead.c        |   12 ++++++------
 crypto/ahash.c       |    6 +++---
 crypto/blkcipher.c   |    6 +++---
 crypto/crypto_user.c |   22 +++++++++++-----------
 crypto/pcompress.c   |    6 +++---
 crypto/rng.c         |    6 +++---
 crypto/shash.c       |    6 +++---
 8 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/crypto/ablkcipher.c b/crypto/ablkcipher.c
index a0f768c..c22374b 100644
--- a/crypto/ablkcipher.c
+++ b/crypto/ablkcipher.c
@@ -397,9 +397,9 @@ static int crypto_ablkcipher_report(struct sk_buff *skb, struct crypto_alg *alg)
 	rblkcipher.max_keysize = alg->cra_ablkcipher.max_keysize;
 	rblkcipher.ivsize = alg->cra_ablkcipher.ivsize;
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_BLKCIPHER,
-		sizeof(struct crypto_report_blkcipher), &rblkcipher);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_BLKCIPHER,
+		    sizeof(struct crypto_report_blkcipher), &rblkcipher))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -478,9 +478,9 @@ static int crypto_givcipher_report(struct sk_buff *skb, struct crypto_alg *alg)
 	rblkcipher.max_keysize = alg->cra_ablkcipher.max_keysize;
 	rblkcipher.ivsize = alg->cra_ablkcipher.ivsize;
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_BLKCIPHER,
-		sizeof(struct crypto_report_blkcipher), &rblkcipher);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_BLKCIPHER,
+		    sizeof(struct crypto_report_blkcipher), &rblkcipher))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/crypto/aead.c b/crypto/aead.c
index 04add3dc..c772b9c 100644
--- a/crypto/aead.c
+++ b/crypto/aead.c
@@ -125,9 +125,9 @@ static int crypto_aead_report(struct sk_buff *skb, struct crypto_alg *alg)
 	raead.maxauthsize = aead->maxauthsize;
 	raead.ivsize = aead->ivsize;
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_AEAD,
-		sizeof(struct crypto_report_aead), &raead);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_AEAD,
+		    sizeof(struct crypto_report_aead), &raead))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -210,9 +210,9 @@ static int crypto_nivaead_report(struct sk_buff *skb, struct crypto_alg *alg)
 	raead.maxauthsize = aead->maxauthsize;
 	raead.ivsize = aead->ivsize;
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_AEAD,
-		sizeof(struct crypto_report_aead), &raead);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_AEAD,
+		    sizeof(struct crypto_report_aead), &raead))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/crypto/ahash.c b/crypto/ahash.c
index 33bc9b6..3887856 100644
--- a/crypto/ahash.c
+++ b/crypto/ahash.c
@@ -409,9 +409,9 @@ static int crypto_ahash_report(struct sk_buff *skb, struct crypto_alg *alg)
 	rhash.blocksize = alg->cra_blocksize;
 	rhash.digestsize = __crypto_hash_alg_common(alg)->digestsize;
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_HASH,
-		sizeof(struct crypto_report_hash), &rhash);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_HASH,
+		    sizeof(struct crypto_report_hash), &rhash))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/crypto/blkcipher.c b/crypto/blkcipher.c
index 4dd80c7..a8d85a1 100644
--- a/crypto/blkcipher.c
+++ b/crypto/blkcipher.c
@@ -508,9 +508,9 @@ static int crypto_blkcipher_report(struct sk_buff *skb, struct crypto_alg *alg)
 	rblkcipher.max_keysize = alg->cra_blkcipher.max_keysize;
 	rblkcipher.ivsize = alg->cra_blkcipher.ivsize;
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_BLKCIPHER,
-		sizeof(struct crypto_report_blkcipher), &rblkcipher);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_BLKCIPHER,
+		    sizeof(struct crypto_report_blkcipher), &rblkcipher))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index f76e42b..84a5ac7 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -77,9 +77,9 @@ static int crypto_report_cipher(struct sk_buff *skb, struct crypto_alg *alg)
 	rcipher.min_keysize = alg->cra_cipher.cia_min_keysize;
 	rcipher.max_keysize = alg->cra_cipher.cia_max_keysize;
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_CIPHER,
-		sizeof(struct crypto_report_cipher), &rcipher);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_CIPHER,
+		    sizeof(struct crypto_report_cipher), &rcipher))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -92,9 +92,9 @@ static int crypto_report_comp(struct sk_buff *skb, struct crypto_alg *alg)
 
 	snprintf(rcomp.type, CRYPTO_MAX_ALG_NAME, "%s", "compression");
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_COMPRESS,
-		sizeof(struct crypto_report_comp), &rcomp);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_COMPRESS,
+		    sizeof(struct crypto_report_comp), &rcomp))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -113,16 +113,16 @@ static int crypto_report_one(struct crypto_alg *alg,
 	ualg->cru_flags = alg->cra_flags;
 	ualg->cru_refcnt = atomic_read(&alg->cra_refcnt);
 
-	NLA_PUT_U32(skb, CRYPTOCFGA_PRIORITY_VAL, alg->cra_priority);
-
+	if (nla_put_u32(skb, CRYPTOCFGA_PRIORITY_VAL, alg->cra_priority))
+		goto nla_put_failure;
 	if (alg->cra_flags & CRYPTO_ALG_LARVAL) {
 		struct crypto_report_larval rl;
 
 		snprintf(rl.type, CRYPTO_MAX_ALG_NAME, "%s", "larval");
 
-		NLA_PUT(skb, CRYPTOCFGA_REPORT_LARVAL,
-			sizeof(struct crypto_report_larval), &rl);
-
+		if (nla_put(skb, CRYPTOCFGA_REPORT_LARVAL,
+			    sizeof(struct crypto_report_larval), &rl))
+			goto nla_put_failure;
 		goto out;
 	}
 
diff --git a/crypto/pcompress.c b/crypto/pcompress.c
index 2e458e5..04e083f 100644
--- a/crypto/pcompress.c
+++ b/crypto/pcompress.c
@@ -55,9 +55,9 @@ static int crypto_pcomp_report(struct sk_buff *skb, struct crypto_alg *alg)
 
 	snprintf(rpcomp.type, CRYPTO_MAX_ALG_NAME, "%s", "pcomp");
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_COMPRESS,
-		sizeof(struct crypto_report_comp), &rpcomp);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_COMPRESS,
+		    sizeof(struct crypto_report_comp), &rpcomp))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/crypto/rng.c b/crypto/rng.c
index 64f864f..f3b7894 100644
--- a/crypto/rng.c
+++ b/crypto/rng.c
@@ -69,9 +69,9 @@ static int crypto_rng_report(struct sk_buff *skb, struct crypto_alg *alg)
 
 	rrng.seedsize = alg->cra_rng.seedsize;
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_RNG,
-		sizeof(struct crypto_report_rng), &rrng);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_RNG,
+		    sizeof(struct crypto_report_rng), &rrng))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/crypto/shash.c b/crypto/shash.c
index 21fc12e..32067f4 100644
--- a/crypto/shash.c
+++ b/crypto/shash.c
@@ -534,9 +534,9 @@ static int crypto_shash_report(struct sk_buff *skb, struct crypto_alg *alg)
 	rhash.blocksize = alg->cra_blocksize;
 	rhash.digestsize = salg->digestsize;
 
-	NLA_PUT(skb, CRYPTOCFGA_REPORT_HASH,
-		sizeof(struct crypto_report_hash), &rhash);
-
+	if (nla_put(skb, CRYPTOCFGA_REPORT_HASH,
+		    sizeof(struct crypto_report_hash), &rhash))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
