From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] [iproute] ipxfrm: simplify algo code a bit
Date: Thu, 17 Jan 2013 21:39:06 -0500
Message-ID: <1358476746-10810-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:40111 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020Ab3ARCfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 21:35:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code sets up a structure with xfrm_algo embedded in it, but
doesn't use the supplemental key field.  Drop it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
note: i don't have a system where this code runs (probably missing options in
my kernel).  i checked xfrm_aead_print a bit but couldn't quite figure it out.
it doesn't seem like it needs that trailing space.

 ip/ipxfrm.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index c7b3420..bd313e6 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -555,16 +555,13 @@ static inline void xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
 static void xfrm_aead_print(struct xfrm_algo_aead *algo, int len,
 			    FILE *fp, const char *prefix)
 {
-	struct {
-		struct xfrm_algo algo;
-		char key[algo->alg_key_len / 8];
-	} base;
+	struct xfrm_algo base_algo;
 
-	memcpy(base.algo.alg_name, algo->alg_name, sizeof(base.algo.alg_name));
-	base.algo.alg_key_len = algo->alg_key_len;
-	memcpy(base.algo.alg_key, algo->alg_key, algo->alg_key_len / 8);
+	memcpy(base_algo.alg_name, algo->alg_name, sizeof(base_algo.alg_name));
+	base_algo.alg_key_len = algo->alg_key_len;
+	memcpy(base_algo.alg_key, algo->alg_key, algo->alg_key_len / 8);
 
-	__xfrm_algo_print(&base.algo, XFRMA_ALG_AEAD, len, fp, prefix, 0);
+	__xfrm_algo_print(&base_algo, XFRMA_ALG_AEAD, len, fp, prefix, 0);
 
 	fprintf(fp, " %d", algo->alg_icv_len);
 
@@ -574,16 +571,13 @@ static void xfrm_aead_print(struct xfrm_algo_aead *algo, int len,
 static void xfrm_auth_trunc_print(struct xfrm_algo_auth *algo, int len,
 				  FILE *fp, const char *prefix)
 {
-	struct {
-		struct xfrm_algo algo;
-		char key[algo->alg_key_len / 8];
-	} base;
+	struct xfrm_algo base_algo;
 
-	memcpy(base.algo.alg_name, algo->alg_name, sizeof(base.algo.alg_name));
-	base.algo.alg_key_len = algo->alg_key_len;
-	memcpy(base.algo.alg_key, algo->alg_key, algo->alg_key_len / 8);
+	memcpy(base_algo.alg_name, algo->alg_name, sizeof(base_algo.alg_name));
+	base_algo.alg_key_len = algo->alg_key_len;
+	memcpy(base_algo.alg_key, algo->alg_key, algo->alg_key_len / 8);
 
-	__xfrm_algo_print(&base.algo, XFRMA_ALG_AUTH_TRUNC, len, fp, prefix, 0);
+	__xfrm_algo_print(&base_algo, XFRMA_ALG_AUTH_TRUNC, len, fp, prefix, 0);
 
 	fprintf(fp, " %d", algo->alg_trunc_len);
 
-- 
1.8.0.2
