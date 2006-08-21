From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 14/18] d80211:  make lowlevel TX framedump option visible
Date: Mon, 21 Aug 2006 09:41:21 +0200
Message-ID: <20060821075201.926978449@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59840 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030332AbWHUICR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:17 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-make-framedump-selectable.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch surfaces the lowlevel TX framedump option in Kconfig.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/Kconfig	2006-08-20 17:28:47.578192788 +0200
+++ wireless-dev/net/d80211/Kconfig	2006-08-20 19:30:45.722819787 +0200
@@ -29,6 +29,19 @@ config D80211_VERBOSE_DEBUG
 	bool "Verbose debugging output"
 	depends on D80211_DEBUG
 
+config D80211_LOWTX_FRAME_DUMP
+	bool "Debug frame dumping"
+	depends on D80211_DEBUG
+	---help---
+	  Selecting this option will cause the stack to
+	  print a message for each frame that is handed
+	  to the lowlevel driver for transmission. This
+	  message includes all MAC addresses and the
+	  frame control field.
+
+	  If unsure, say N and insert the debugging code
+	  you require into the driver you are debugging.
+
 config TKIP_DEBUG
 	bool "TKIP debugging"
 	depends on D80211_DEBUG
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 17:28:09.988192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 19:30:14.732819787 +0200
@@ -271,7 +271,7 @@ int ieee80211_get_hdrlen_from_skb(struct
 EXPORT_SYMBOL(ieee80211_get_hdrlen_from_skb);
 
 
-#ifdef IEEE80211_VERBOSE_DEBUG_FRAME_DUMP
+#ifdef CONFIG_D80211_LOWTX_FRAME_DUMP
 static void ieee80211_dump_frame(const char *ifname, const char *title,
 				 struct sk_buff *skb)
 {
@@ -302,12 +302,12 @@ static void ieee80211_dump_frame(const c
 		printk(" A4=" MAC_FMT, MAC_ARG(hdr->addr4));
 	printk("\n");
 }
-#else /* IEEE80211_VERBOSE_DEBUG_FRAME_DUMP */
+#else /* CONFIG_D80211_LOWTX_FRAME_DUMP */
 static inline void ieee80211_dump_frame(const char *ifname, const char *title,
 					struct sk_buff *skb)
 {
 }
-#endif /* IEEE80211_VERBOSE_DEBUG_FRAME_DUMP */
+#endif /* CONFIG_D80211_LOWTX_FRAME_DUMP */
 
 
 static int ieee80211_is_eapol(struct sk_buff *skb)

--
