From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 04/26] IPVS: Add address family specific debugging macros.
Date: Wed, 11 Jun 2008 19:11:47 +0200
Message-ID: <1213204329-10973-5-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com,
	"Julius R. Volz" <juliusv@google.com>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:14472 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbYFKRMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 13:12:34 -0400
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define debugging/error logging macros that only do something for a
specific address family. Avoids ugly conditionals in code using these
debugging macros.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b7b181e..349a746 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -287,6 +287,24 @@ struct ip_vs_daemon_user {
 #include <linux/net.h>
 
 extern int ip_vs_get_debug_level(void);
+#define IP_VS_DBG_V4(af, level, msg...)			\
+    do {						\
+	    if (af == AF_INET				\
+		&& level <= ip_vs_get_debug_level())	\
+		    printk(KERN_DEBUG "IPVS: " msg);	\
+    } while (0)
+
+#ifdef CONFIG_IP_VS_IPV6
+#define IP_VS_DBG_V6(af, level, msg...)			\
+    do {						\
+	    if (af == AF_INET6				\
+		&& level <= ip_vs_get_debug_level())	\
+		    printk(KERN_DEBUG "IPVS: " msg);	\
+    } while (0)
+#else
+#define IP_VS_DBG_V6(af, level, msg...)	do {} while (0)
+#endif
+
 #define IP_VS_DBG(level, msg...)			\
     do {						\
 	    if (level <= ip_vs_get_debug_level())	\
@@ -309,6 +327,8 @@ extern int ip_vs_get_debug_level(void);
 		pp->debug_packet(pp, skb, ofs, msg);	\
     } while (0)
 #else	/* NO DEBUGGING at ALL */
+#define IP_VS_DBG_V4(af, level, msg...)  do {} while (0)
+#define IP_VS_DBG_V6(af, level, msg...)  do {} while (0)
 #define IP_VS_DBG(level, msg...)  do {} while (0)
 #define IP_VS_DBG_RL(msg...)  do {} while (0)
 #define IP_VS_DBG_PKT(level, pp, skb, ofs, msg)		do {} while (0)
@@ -316,6 +336,20 @@ extern int ip_vs_get_debug_level(void);
 #endif
 
 #define IP_VS_BUG() BUG()
+#define IP_VS_ERR_V4(af, msg...)			\
+    do {						\
+	    if (af == AF_INET)				\
+	        printk(KERN_ERR "IPVS: " msg);		\
+    } while (0)
+#ifdef CONFIG_IP_VS_IPV6
+#define IP_VS_ERR_V6(af, msg...)			\
+do {							\
+	    if (af == AF_INET6)				\
+	        printk(KERN_ERR "IPVS: " msg);		\
+    } while (0)
+#else
+#define IP_VS_ERR_V6(af, msg...) do {} while (0)
+#endif
 #define IP_VS_ERR(msg...) printk(KERN_ERR "IPVS: " msg)
 #define IP_VS_INFO(msg...) printk(KERN_INFO "IPVS: " msg)
 #define IP_VS_WARNING(msg...) \
-- 
1.5.3.6

