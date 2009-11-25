From: Martin Willi <martin@strongswan.org>
Subject: [PATCH] xfrm: Add SHA384 and SHA512 HMAC authentication algorithms to XFRM
Date: Wed, 25 Nov 2009 11:58:39 +0100
Message-ID: <1259146719-16359-1-git-send-email-martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These algorithms use a truncation of 192/256 bits, as specified
in RFC4868.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 net/xfrm/xfrm_algo.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index faf54c6..480afda 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -200,6 +200,40 @@ static struct xfrm_algo_desc aalg_list[] = {
 	}
 },
 {
+	.name = "hmac(sha384)",
+
+	.uinfo = {
+		.auth = {
+			.icv_truncbits = 192,
+			.icv_fullbits = 384,
+		}
+	},
+
+	.desc = {
+		.sadb_alg_id = SADB_X_AALG_SHA2_384HMAC,
+		.sadb_alg_ivlen = 0,
+		.sadb_alg_minbits = 384,
+		.sadb_alg_maxbits = 384
+	}
+},
+{
+	.name = "hmac(sha512)",
+
+	.uinfo = {
+		.auth = {
+			.icv_truncbits = 256,
+			.icv_fullbits = 512,
+		}
+	},
+
+	.desc = {
+		.sadb_alg_id = SADB_X_AALG_SHA2_512HMAC,
+		.sadb_alg_ivlen = 0,
+		.sadb_alg_minbits = 512,
+		.sadb_alg_maxbits = 512
+	}
+},
+{
 	.name = "hmac(rmd160)",
 	.compat = "rmd160",
 
-- 
1.6.3.3

