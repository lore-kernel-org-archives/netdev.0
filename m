From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 6/13] xfrm: Add IV generator information to xfrm_algo_desc
Date: Fri, 22 May 2015 16:30:54 +0800
Message-ID: <E1YviM2-0000yB-Pe@gondolin.me.apana.org.au>
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

This patch adds IV generator information for each AEAD and block
cipher to xfrm_algo_desc.  This will be used to access the new
AEAD interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h   |    2 ++
 net/xfrm/xfrm_algo.c |   16 ++++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 36ac102..30bca86 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1314,6 +1314,7 @@ static inline int xfrm_id_proto_match(u8 proto, u8 userproto)
  * xfrm algorithm information
  */
 struct xfrm_algo_aead_info {
+	char *geniv;
 	u16 icv_truncbits;
 };
 
@@ -1323,6 +1324,7 @@ struct xfrm_algo_auth_info {
 };
 
 struct xfrm_algo_encr_info {
+	char *geniv;
 	u16 blockbits;
 	u16 defkeybits;
 };
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 12e82a5..67266b7 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -31,6 +31,7 @@ static struct xfrm_algo_desc aead_list[] = {
 
 	.uinfo = {
 		.aead = {
+			.geniv = "seqniv",
 			.icv_truncbits = 64,
 		}
 	},
@@ -49,6 +50,7 @@ static struct xfrm_algo_desc aead_list[] = {
 
 	.uinfo = {
 		.aead = {
+			.geniv = "seqniv",
 			.icv_truncbits = 96,
 		}
 	},
@@ -67,6 +69,7 @@ static struct xfrm_algo_desc aead_list[] = {
 
 	.uinfo = {
 		.aead = {
+			.geniv = "seqniv",
 			.icv_truncbits = 128,
 		}
 	},
@@ -85,6 +88,7 @@ static struct xfrm_algo_desc aead_list[] = {
 
 	.uinfo = {
 		.aead = {
+			.geniv = "seqniv",
 			.icv_truncbits = 64,
 		}
 	},
@@ -103,6 +107,7 @@ static struct xfrm_algo_desc aead_list[] = {
 
 	.uinfo = {
 		.aead = {
+			.geniv = "seqniv",
 			.icv_truncbits = 96,
 		}
 	},
@@ -121,6 +126,7 @@ static struct xfrm_algo_desc aead_list[] = {
 
 	.uinfo = {
 		.aead = {
+			.geniv = "seqniv",
 			.icv_truncbits = 128,
 		}
 	},
@@ -139,6 +145,7 @@ static struct xfrm_algo_desc aead_list[] = {
 
 	.uinfo = {
 		.aead = {
+			.geniv = "seqiv",
 			.icv_truncbits = 128,
 		}
 	},
@@ -353,6 +360,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 
 	.uinfo = {
 		.encr = {
+			.geniv = "echainiv",
 			.blockbits = 64,
 			.defkeybits = 64,
 		}
@@ -373,6 +381,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 
 	.uinfo = {
 		.encr = {
+			.geniv = "echainiv",
 			.blockbits = 64,
 			.defkeybits = 192,
 		}
@@ -393,6 +402,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 
 	.uinfo = {
 		.encr = {
+			.geniv = "echainiv",
 			.blockbits = 64,
 			.defkeybits = 128,
 		}
@@ -413,6 +423,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 
 	.uinfo = {
 		.encr = {
+			.geniv = "echainiv",
 			.blockbits = 64,
 			.defkeybits = 128,
 		}
@@ -433,6 +444,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 
 	.uinfo = {
 		.encr = {
+			.geniv = "echainiv",
 			.blockbits = 128,
 			.defkeybits = 128,
 		}
@@ -453,6 +465,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 
 	.uinfo = {
 		.encr = {
+			.geniv = "echainiv",
 			.blockbits = 128,
 			.defkeybits = 128,
 		}
@@ -473,6 +486,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 
 	.uinfo = {
 		.encr = {
+			.geniv = "echainiv",
 			.blockbits = 128,
 			.defkeybits = 128,
 		}
@@ -493,6 +507,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 
 	.uinfo = {
 		.encr = {
+			.geniv = "echainiv",
 			.blockbits = 128,
 			.defkeybits = 128,
 		}
@@ -512,6 +527,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 
 	.uinfo = {
 		.encr = {
+			.geniv = "seqiv",
 			.blockbits = 128,
 			.defkeybits = 160, /* 128-bit key + 32-bit nonce */
 		}
