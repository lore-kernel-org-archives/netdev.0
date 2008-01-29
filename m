From: Joy Latten <latten@austin.ibm.com>
Subject: PATCH[1/1]: Add ctr-aes support to ipsec
Date: Tue, 29 Jan 2008 14:18:24 -0600
Message-ID: <200801292018.m0TKIOLA011876@faith.austin.ibm.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:54909 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbYA2UUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 15:20:35 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0TJH5i4004742
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 14:17:05 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0TKKTP2178348
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 13:20:29 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0TKKTQI030615
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 13:20:29 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The below patch allows IPsec to use CTR mode with
AES encryption algorithm. Tested this using setkey
in ipsec-tools.

regards,
Joy

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
