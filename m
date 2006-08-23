From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 10/21] d80211: make lowlevel TX framedump option visible
Date: Wed, 23 Aug 2006 21:24:19 +0200 (CEST)
Message-ID: <20060823192419.2F400483AA@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:28880 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965135AbWHWTYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:18 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch surfaces the lowlevel TX framedump option in Kconfig.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/Kconfig     |   13 +++++++++++++
 net/d80211/ieee80211.c |    6 +++---
 2 files changed, 16 insertions(+), 3 deletions(-)

bebc14745291105672e2cc3c46821e1c0731b330
diff --git a/net/d80211/Kconfig b/net/d80211/Kconfig
index 36df52d..ffe2bdf 100644
--- a/net/d80211/Kconfig
+++ b/net/d80211/Kconfig
@@ -21,6 +21,19 @@ config D80211_VERBOSE_DEBUG
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
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index b9bea6a..96ef85a 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -284,7 +284,7 @@ int ieee80211_get_hdrlen_from_skb(struct
 }
 EXPORT_SYMBOL(ieee80211_get_hdrlen_from_skb);
 
-#ifdef IEEE80211_VERBOSE_DEBUG_FRAME_DUMP
+#ifdef CONFIG_D80211_LOWTX_FRAME_DUMP
 static void ieee80211_dump_frame(const char *ifname, const char *title,
 				 struct sk_buff *skb)
 {
@@ -315,12 +315,12 @@ static void ieee80211_dump_frame(const c
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
1.3.0

