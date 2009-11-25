From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 1/3] xfrm: Define new XFRM netlink auth attribute with specified truncation bits
Date: Wed, 25 Nov 2009 11:29:51 +0100
Message-ID: <1d70ade2a447f1c43a78ca813f46222859f70b5a.1259142145.git.martin@strongswan.org>
References: <cover.1259142145.git.martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1259142145.git.martin@strongswan.org>
In-Reply-To: <cover.1259142145.git.martin@strongswan.org>
References: <cover.1259142145.git.martin@strongswan.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new XFRMA_ALG_AUTH_TRUNC attribute taking a xfrm_algo_auth as
argument allows the installation of authentication algorithms with
a truncation length specified in userspace, i.e. SHA256 with 128 bit
instead of 96 bit truncation.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 include/linux/xfrm.h |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 2d4ec15..d28e853 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -96,6 +96,13 @@ struct xfrm_algo {
 	char		alg_key[0];
 };
 
+struct xfrm_algo_auth {
+	char		alg_name[64];
+	unsigned int	alg_key_len;    /* in bits */
+	unsigned int	alg_trunc_len;  /* in bits */
+	char		alg_key[0];
+};
+
 struct xfrm_algo_aead {
 	char		alg_name[64];
 	unsigned int	alg_key_len;	/* in bits */
@@ -283,6 +290,7 @@ enum xfrm_attr_type_t {
 	XFRMA_MIGRATE,
 	XFRMA_ALG_AEAD,		/* struct xfrm_algo_aead */
 	XFRMA_KMADDRESS,        /* struct xfrm_user_kmaddress */
+	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
-- 
1.6.3.3

