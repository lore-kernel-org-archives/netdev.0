From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 8/21] d80211: clean up includes
Date: Wed, 23 Aug 2006 21:24:17 +0200 (CEST)
Message-ID: <20060823192417.1A0E5483A8@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:28880 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965131AbWHWTYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:17 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch cleans up includes all over d80211. It might
not be complete, but this was the best I could do without
analysing it completely.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/aes_ccm.c         |    1 -
 net/d80211/aes_ccm.h         |    2 +-
 net/d80211/fifo_qdisc.c      |    4 +---
 net/d80211/ieee80211.c       |    2 --
 net/d80211/ieee80211_ioctl.c |    2 --
 net/d80211/ieee80211_key.h   |    1 +
 net/d80211/ieee80211_scan.c  |    2 --
 net/d80211/ieee80211_sta.c   |    2 --
 net/d80211/rate_control.c    |    2 --
 net/d80211/sta_info.c        |    3 +--
 net/d80211/sta_info.h        |    4 ++--
 net/d80211/tkip.c            |   15 ---------------
 net/d80211/tkip.h            |    1 +
 net/d80211/wep.c             |    2 --
 net/d80211/wme.c             |    2 --
 net/d80211/wpa.c             |    4 ----
 16 files changed, 7 insertions(+), 42 deletions(-)

681294dce73ff7ea535636dd0a5aeb288744db2d
diff --git a/net/d80211/aes_ccm.c b/net/d80211/aes_ccm.c
index 8d1045c..693b822 100644
--- a/net/d80211/aes_ccm.c
+++ b/net/d80211/aes_ccm.c
@@ -8,7 +8,6 @@
  */
 
 #include <linux/types.h>
-#include <linux/netdevice.h>
 #include <linux/crypto.h>
 #include <asm/scatterlist.h>
 
diff --git a/net/d80211/aes_ccm.h b/net/d80211/aes_ccm.h
index 1544f5a..e900b36 100644
--- a/net/d80211/aes_ccm.h
+++ b/net/d80211/aes_ccm.h
@@ -10,7 +10,7 @@
 #ifndef AES_CCM_H
 #define AES_CCM_H
 
-#include <linux/types.h>
+#include <linux/crypto.h>
 
 #define AES_BLOCK_LEN 16
 
diff --git a/net/d80211/fifo_qdisc.c b/net/d80211/fifo_qdisc.c
index a89a839..12aaed5 100644
--- a/net/d80211/fifo_qdisc.c
+++ b/net/d80211/fifo_qdisc.c
@@ -10,9 +10,7 @@
  * This is a simple replacement for sch_fifo.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
-#include <linux/netdevice.h>
+#include <linux/skbuff.h>
 #include <net/pkt_sched.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 9416538..c136859 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -7,8 +7,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index db8e8ba..35e4711 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -7,8 +7,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
diff --git a/net/d80211/ieee80211_key.h b/net/d80211/ieee80211_key.h
index 64f2363..1613594 100644
--- a/net/d80211/ieee80211_key.h
+++ b/net/d80211/ieee80211_key.h
@@ -11,6 +11,7 @@ #ifndef IEEE80211_KEY_H
 #define IEEE80211_KEY_H
 
 #include <linux/types.h>
+#include <linux/kobject.h>
 #include <net/d80211.h>
 
 /* ALG_TKIP
diff --git a/net/d80211/ieee80211_scan.c b/net/d80211/ieee80211_scan.c
index 539b8a2..8ed1e39 100644
--- a/net/d80211/ieee80211_scan.c
+++ b/net/d80211/ieee80211_scan.c
@@ -6,8 +6,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/types.h>
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 645529f..0c5bf88 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -15,8 +15,6 @@
  * scan result table filtering (by capability (privacy, IBSS/BSS, WPA/RSN IE,
  *    SSID)
  */
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/if_ether.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index ff383ab..5f03629 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
@@ -7,8 +7,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 5d4b001..622b234 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -6,8 +6,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kobject.h>
@@ -20,6 +18,7 @@ #include <linux/if_arp.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
 #include "rate_control.h"
+#include "sta_info.h"
 
 
 /* Caller must hold local->sta_lock */
diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index 1f0f845..f7a56c0 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -9,9 +9,9 @@
 #ifndef STA_INFO_H
 #define STA_INFO_H
 
-#include <linux/if_ether.h>
+#include <linux/list.h>
 #include <linux/types.h>
-#include "ieee80211_i.h"
+#include <linux/if_ether.h>
 #include "ieee80211_key.h"
 
 /* Stations flags (struct sta_info::flags) */
diff --git a/net/d80211/tkip.c b/net/d80211/tkip.c
index c27a7fe..7e3665a 100644
--- a/net/d80211/tkip.c
+++ b/net/d80211/tkip.c
@@ -7,28 +7,13 @@
  * published by the Free Software Foundation.
  */
 
-#ifdef CONFIG_TKIP_DEBUG
-#include <linux/config.h>
-#include <linux/version.h>
-#include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/skbuff.h>
-#endif /* CONFIG_TKIP_DEBUG */
-
 #include <linux/types.h>
 #include <linux/netdevice.h>
 
 #include <net/d80211.h>
 #include "ieee80211_key.h"
-#ifdef CONFIG_TKIP_DEBUG
-#include "ieee80211_i.h"
-#endif /* CONFIG_TKIP_DEBUG */
 #include "tkip.h"
-
-/* Dummy prototypes for structures used in wep.h, but not really needed for
- * TKIP. */
-struct ieee80211_local;
-struct sk_buff;
 #include "wep.h"
 
 
diff --git a/net/d80211/tkip.h b/net/d80211/tkip.h
index dc66421..e36b85c 100644
--- a/net/d80211/tkip.h
+++ b/net/d80211/tkip.h
@@ -10,6 +10,7 @@ #ifndef TKIP_H
 #define TKIP_H
 
 #include <linux/types.h>
+#include <linux/crypto.h>
 #include "ieee80211_key.h"
 
 u8 * ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,
diff --git a/net/d80211/wep.c b/net/d80211/wep.c
index 097a7e9..c3e4728 100644
--- a/net/d80211/wep.c
+++ b/net/d80211/wep.c
@@ -8,8 +8,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/random.h>
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index b1ff066..60dd8c2 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -6,8 +6,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/module.h>
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index 5270b8c..412b4a6 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -6,15 +6,11 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
-#include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/skbuff.h>
 #include <linux/compiler.h>
-#include <linux/wireless.h>
 #include <net/iw_handler.h>
 
 #include <net/d80211.h>
-- 
1.3.0

