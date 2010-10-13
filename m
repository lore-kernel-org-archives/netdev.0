From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] cxgb4vf: make single bit signed bitfields unsigned
Date: Wed, 13 Oct 2010 00:52:26 -0700
Message-ID: <1286956346-17147-1-git-send-email-harvey.harrison@gmail.com>
Cc: Harvey Harrison <harvey.harrison@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:36438 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab0JMHwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 03:52:33 -0400
Received: by pzk34 with SMTP id 34so1427029pzk.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 00:52:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Single bit signed bitfields don't make a lot of sense, noticed by sparse:
drivers/net/cxgb4vf/t4vf_common.h:135:31: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:136:36: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:137:36: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:138:36: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:139:36: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:140:31: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:141:31: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:142:35: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:143:35: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:154:27: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:155:26: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:156:27: error: dubious one-bit signed bitfield
drivers/net/cxgb4vf/t4vf_common.h:157:26: error: dubious one-bit signed bitfield

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/cxgb4vf/t4vf_common.h |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/cxgb4vf/t4vf_common.h b/drivers/net/cxgb4vf/t4vf_common.h
index 5c7bde7..873cb7d 100644
--- a/drivers/net/cxgb4vf/t4vf_common.h
+++ b/drivers/net/cxgb4vf/t4vf_common.h
@@ -132,15 +132,15 @@ struct rss_params {
 	unsigned int mode;		/* RSS mode */
 	union {
 	    struct {
-		int synmapen:1;		/* SYN Map Enable */
-		int syn4tupenipv6:1;	/* enable hashing 4-tuple IPv6 SYNs */
-		int syn2tupenipv6:1;	/* enable hashing 2-tuple IPv6 SYNs */
-		int syn4tupenipv4:1;	/* enable hashing 4-tuple IPv4 SYNs */
-		int syn2tupenipv4:1;	/* enable hashing 2-tuple IPv4 SYNs */
-		int ofdmapen:1;		/* Offload Map Enable */
-		int tnlmapen:1;		/* Tunnel Map Enable */
-		int tnlalllookup:1;	/* Tunnel All Lookup */
-		int hashtoeplitz:1;	/* use Toeplitz hash */
+		unsigned int synmapen:1;	/* SYN Map Enable */
+		unsigned int syn4tupenipv6:1;	/* enable hashing 4-tuple IPv6 SYNs */
+		unsigned int syn2tupenipv6:1;	/* enable hashing 2-tuple IPv6 SYNs */
+		unsigned int syn4tupenipv4:1;	/* enable hashing 4-tuple IPv4 SYNs */
+		unsigned int syn2tupenipv4:1;	/* enable hashing 2-tuple IPv4 SYNs */
+		unsigned int ofdmapen:1;	/* Offload Map Enable */
+		unsigned int tnlmapen:1;	/* Tunnel Map Enable */
+		unsigned int tnlalllookup:1;	/* Tunnel All Lookup */
+		unsigned int hashtoeplitz:1;	/* use Toeplitz hash */
 	    } basicvirtual;
 	} u;
 };
@@ -151,10 +151,10 @@ struct rss_params {
 union rss_vi_config {
     struct {
 	u16 defaultq;			/* Ingress Queue ID for !tnlalllookup */
-	int ip6fourtupen:1;		/* hash 4-tuple IPv6 ingress packets */
-	int ip6twotupen:1;		/* hash 2-tuple IPv6 ingress packets */
-	int ip4fourtupen:1;		/* hash 4-tuple IPv4 ingress packets */
-	int ip4twotupen:1;		/* hash 2-tuple IPv4 ingress packets */
+	unsigned int ip6fourtupen:1;	/* hash 4-tuple IPv6 ingress packets */
+	unsigned int ip6twotupen:1;	/* hash 2-tuple IPv6 ingress packets */
+	unsigned int ip4fourtupen:1;	/* hash 4-tuple IPv4 ingress packets */
+	unsigned int ip4twotupen:1;	/* hash 2-tuple IPv4 ingress packets */
 	int udpen;			/* hash 4-tuple UDP ingress packets */
     } basicvirtual;
 };
-- 
1.7.1

