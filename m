From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] [NET] restructure LL_MAX_HEADER code, increase headroom for
	802.11
Date: Sun, 04 May 2008 20:44:01 +0200
Message-ID: <1209926641.3655.20.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59536 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbYEDSoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 14:44:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds new default headroom for 802.11 and restructures the defines
there to be more readable using #elif.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 include/linux/netdevice.h |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

--- everything.orig/include/linux/netdevice.h	2008-05-04 13:21:27.000000000 +0200
+++ everything/include/linux/netdevice.h	2008-05-04 13:22:34.000000000 +0200
@@ -91,16 +91,26 @@ struct wireless_dev;
 /*
  *	Compute the worst case header length according to the protocols
  *	used.
+ *
+ *	These must be ordered by decreasing size for obvious reasons.
  */
  
-#if !defined(CONFIG_AX25) && !defined(CONFIG_AX25_MODULE) && !defined(CONFIG_TR)
-#define LL_MAX_HEADER	32
-#else
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 #define LL_MAX_HEADER	96
-#else
+#elif defined(MAC80211_MESH)
+/* 802.11 (see below) plus 6-byte mesh header */
+#define LL_MAX_HEADER	54
+#elif defined(CONFIG_MAC80211) || defined(CONFIG_MAC80211_module)
+/*
+ * ctl (2), seq (2), addr1 (6), addr2 (6), addr3 (6),
+ * seq (2), addr4 (2), qos (2), extended IV (8),
+ * rfc1042/bridge tunnel (8)
+ */
 #define LL_MAX_HEADER	48
-#endif
+#elif defined(CONFIG_TR)
+#define LL_MAX_HEADER	48
+#else
+#define LL_MAX_HEADER	32
 #endif
 
 #if !defined(CONFIG_NET_IPIP) && !defined(CONFIG_NET_IPIP_MODULE) && \


