From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH 1/1]: Add support for aes-ctr to ipsec
Date: Thu, 31 Jan 2008 10:59:28 -0600
Message-ID: <200801311659.m0VGxSTN025939@faith.austin.ibm.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:34181 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763293AbYAaRBz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 12:01:55 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0VH1aUt004021
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 12:01:36 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0VH1aZk249736
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 12:01:36 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0VH1ZCn015723
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 12:01:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Very sorry, re-posting as first patch was incomplete.

The below patch allows IPsec to use CTR mode with
AES encryption algorithm. Tested this using setkey
in ipsec-tools.

regards,
Joy


Signed-off-by: Joy Latten <latten@austin.ibm.com>

--

diff -urpN net-2.6.25/include/linux/pfkeyv2.h net-2.6.25.patch/include/linux/pfkeyv2.h
--- net-2.6.25/include/linux/pfkeyv2.h	2008-01-29 11:48:00.000000000 -0600
+++ net-2.6.25.patch/include/linux/pfkeyv2.h	2008-01-29 13:43:59.000000000 -0600
@@ -298,6 +298,7 @@ struct sadb_x_sec_ctx {
 #define SADB_X_EALG_BLOWFISHCBC		7
 #define SADB_EALG_NULL			11
 #define SADB_X_EALG_AESCBC		12
+#define SADB_X_EALG_AESCTR		13
 #define SADB_X_EALG_CAMELLIACBC		22
 #define SADB_EALG_MAX                   253 /* last EALG */
 /* private allocations should use 249-255 (RFC2407) */
diff -urpN net-2.6.25/net/xfrm/xfrm_algo.c net-2.6.25.patch/net/xfrm/xfrm_algo.c
--- net-2.6.25/net/xfrm/xfrm_algo.c	2008-01-29 11:48:03.000000000 -0600
+++ net-2.6.25.patch/net/xfrm/xfrm_algo.c	2008-01-29 13:42:43.000000000 -0600
@@ -300,6 +300,23 @@ static struct xfrm_algo_desc ealg_list[]
 		.sadb_alg_maxbits = 256
 	}
 },
+{
+	.name = "rfc3686(ctr(aes))",
+
+	.uinfo = {
+		.encr = {
+			.blockbits = 128,
+			.defkeybits = 160, /* 128-bit key + 32-bit nonce */
+		}
+	},
+
+	.desc = {
+		.sadb_alg_id = SADB_X_EALG_AESCTR,
+		.sadb_alg_ivlen	= 8,
+		.sadb_alg_minbits = 128,
+		.sadb_alg_maxbits = 256
+	}
+},
 };
 
 static struct xfrm_algo_desc calg_list[] = {
