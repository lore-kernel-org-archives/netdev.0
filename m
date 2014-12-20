From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ceph: crypto.c:  Remove some unused functions
Date: Sat, 20 Dec 2014 17:52:06 +0100
Message-ID: <1419094326-9218-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removes some functions that are not used anywhere:
ceph_encrypt() ceph_decrypt() ceph_crypto_key_encode()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 net/ceph/crypto.c |   52 ----------------------------------------------------
 net/ceph/crypto.h |    7 -------
 2 files changed, 59 deletions(-)

diff --git a/net/ceph/crypto.c b/net/ceph/crypto.c
index 62fc5e7..5a82890 100644
--- a/net/ceph/crypto.c
+++ b/net/ceph/crypto.c
@@ -22,18 +22,6 @@ int ceph_crypto_key_clone(struct ceph_crypto_key *dst,
 	return 0;
 }
 
-int ceph_crypto_key_encode(struct ceph_crypto_key *key, void **p, void *end)
-{
-	if (*p + sizeof(u16) + sizeof(key->created) +
-	    sizeof(u16) + key->len > end)
-		return -ERANGE;
-	ceph_encode_16(p, key->type);
-	ceph_encode_copy(p, &key->created, sizeof(key->created));
-	ceph_encode_16(p, key->len);
-	ceph_encode_copy(p, key->key, key->len);
-	return 0;
-}
-
 int ceph_crypto_key_decode(struct ceph_crypto_key *key, void **p, void *end)
 {
 	ceph_decode_need(p, end, 2*sizeof(u16) + sizeof(key->created), bad);
@@ -329,26 +317,6 @@ static int ceph_aes_decrypt2(const void *key, int key_len,
 }
 
 
-int ceph_decrypt(struct ceph_crypto_key *secret, void *dst, size_t *dst_len,
-		 const void *src, size_t src_len)
-{
-	switch (secret->type) {
-	case CEPH_CRYPTO_NONE:
-		if (*dst_len < src_len)
-			return -ERANGE;
-		memcpy(dst, src, src_len);
-		*dst_len = src_len;
-		return 0;
-
-	case CEPH_CRYPTO_AES:
-		return ceph_aes_decrypt(secret->key, secret->len, dst,
-					dst_len, src, src_len);
-
-	default:
-		return -EINVAL;
-	}
-}
-
 int ceph_decrypt2(struct ceph_crypto_key *secret,
 			void *dst1, size_t *dst1_len,
 			void *dst2, size_t *dst2_len,
@@ -382,26 +350,6 @@ int ceph_decrypt2(struct ceph_crypto_key *secret,
 	}
 }
 
-int ceph_encrypt(struct ceph_crypto_key *secret, void *dst, size_t *dst_len,
-		 const void *src, size_t src_len)
-{
-	switch (secret->type) {
-	case CEPH_CRYPTO_NONE:
-		if (*dst_len < src_len)
-			return -ERANGE;
-		memcpy(dst, src, src_len);
-		*dst_len = src_len;
-		return 0;
-
-	case CEPH_CRYPTO_AES:
-		return ceph_aes_encrypt(secret->key, secret->len, dst,
-					dst_len, src, src_len);
-
-	default:
-		return -EINVAL;
-	}
-}
-
 int ceph_encrypt2(struct ceph_crypto_key *secret, void *dst, size_t *dst_len,
 		  const void *src1, size_t src1_len,
 		  const void *src2, size_t src2_len)
diff --git a/net/ceph/crypto.h b/net/ceph/crypto.h
index d149822..36082d5 100644
--- a/net/ceph/crypto.h
+++ b/net/ceph/crypto.h
@@ -22,17 +22,10 @@ static inline void ceph_crypto_key_destroy(struct ceph_crypto_key *key)
 
 int ceph_crypto_key_clone(struct ceph_crypto_key *dst,
 			  const struct ceph_crypto_key *src);
-int ceph_crypto_key_encode(struct ceph_crypto_key *key, void **p, void *end);
 int ceph_crypto_key_decode(struct ceph_crypto_key *key, void **p, void *end);
 int ceph_crypto_key_unarmor(struct ceph_crypto_key *key, const char *in);
 
 /* crypto.c */
-int ceph_decrypt(struct ceph_crypto_key *secret,
-		 void *dst, size_t *dst_len,
-		 const void *src, size_t src_len);
-int ceph_encrypt(struct ceph_crypto_key *secret,
-		 void *dst, size_t *dst_len,
-		 const void *src, size_t src_len);
 int ceph_decrypt2(struct ceph_crypto_key *secret,
 		  void *dst1, size_t *dst1_len,
 		  void *dst2, size_t *dst2_len,
-- 
1.7.10.4
