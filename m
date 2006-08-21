From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 10/18] d80211:  clean up includes
Date: Mon, 21 Aug 2006 09:41:17 +0200
Message-ID: <20060821075200.732186689@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:65472 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030320AbWHUICY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:24 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-includes.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch cleans up includes all over d80211. It might
not be complete, but this was the best I could do without
analysing it completely.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/fifo_qdisc.c	2006-08-20 14:56:19.058192788 +0200
+++ wireless-dev/net/d80211/fifo_qdisc.c	2006-08-20 14:56:22.698192788 +0200
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
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 14:56:22.008192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 14:56:22.708192788 +0200
@@ -7,8 +7,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-08-20 14:56:20.588192788 +0200
+++ wireless-dev/net/d80211/ieee80211_ioctl.c	2006-08-20 14:56:22.708192788 +0200
@@ -7,8 +7,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
--- wireless-dev.orig/net/d80211/ieee80211_scan.c	2006-08-20 14:56:17.398192788 +0200
+++ wireless-dev/net/d80211/ieee80211_scan.c	2006-08-20 14:56:22.708192788 +0200
@@ -6,8 +6,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/types.h>
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-08-20 14:56:17.418192788 +0200
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-08-20 14:56:22.718192788 +0200
@@ -15,8 +15,6 @@
  * scan result table filtering (by capability (privacy, IBSS/BSS, WPA/RSN IE,
  *    SSID)
  */
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/if_ether.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
--- wireless-dev.orig/net/d80211/rate_control_simple.c	2006-08-20 14:56:19.768192788 +0200
+++ wireless-dev/net/d80211/rate_control_simple.c	2006-08-20 14:56:22.718192788 +0200
@@ -7,8 +7,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
--- wireless-dev.orig/net/d80211/sta_info.c	2006-08-20 14:56:21.318192788 +0200
+++ wireless-dev/net/d80211/sta_info.c	2006-08-20 14:56:22.718192788 +0200
@@ -6,8 +6,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kobject.h>
@@ -20,6 +18,7 @@
 #include <net/d80211.h>
 #include "ieee80211_i.h"
 #include "rate_control.h"
+#include "sta_info.h"
 
 
 /* Caller must hold local->sta_lock */
--- wireless-dev.orig/net/d80211/tkip.c	2006-08-20 14:56:06.998192788 +0200
+++ wireless-dev/net/d80211/tkip.c	2006-08-20 14:56:22.718192788 +0200
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
 
 
--- wireless-dev.orig/net/d80211/wep.c	2006-08-20 14:56:17.408192788 +0200
+++ wireless-dev/net/d80211/wep.c	2006-08-20 14:56:22.718192788 +0200
@@ -8,8 +8,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/random.h>
--- wireless-dev.orig/net/d80211/wme.c	2006-08-20 14:56:19.058192788 +0200
+++ wireless-dev/net/d80211/wme.c	2006-08-20 14:56:22.718192788 +0200
@@ -6,8 +6,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/version.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/module.h>
--- wireless-dev.orig/net/d80211/wpa.c	2006-08-20 14:56:17.418192788 +0200
+++ wireless-dev/net/d80211/wpa.c	2006-08-20 14:56:22.718192788 +0200
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
--- wireless-dev.orig/net/d80211/aes_ccm.c	2006-08-20 14:56:17.408192788 +0200
+++ wireless-dev/net/d80211/aes_ccm.c	2006-08-20 14:56:22.728192788 +0200
@@ -8,7 +8,6 @@
  */
 
 #include <linux/types.h>
-#include <linux/netdevice.h>
 #include <linux/crypto.h>
 #include <asm/scatterlist.h>
 
--- wireless-dev.orig/net/d80211/aes_ccm.h	2006-08-20 14:56:07.198192788 +0200
+++ wireless-dev/net/d80211/aes_ccm.h	2006-08-20 14:56:22.728192788 +0200
@@ -10,7 +10,7 @@
 #ifndef AES_CCM_H
 #define AES_CCM_H
 
-#include <linux/types.h>
+#include <linux/crypto.h>
 
 #define AES_BLOCK_LEN 16
 
--- wireless-dev.orig/net/d80211/ieee80211_key.h	2006-08-20 14:56:07.218192788 +0200
+++ wireless-dev/net/d80211/ieee80211_key.h	2006-08-20 14:56:22.728192788 +0200
@@ -11,6 +11,7 @@
 #define IEEE80211_KEY_H
 
 #include <linux/types.h>
+#include <linux/kobject.h>
 #include <net/d80211.h>
 
 /* ALG_TKIP
--- wireless-dev.orig/net/d80211/sta_info.h	2006-08-20 14:56:07.258192788 +0200
+++ wireless-dev/net/d80211/sta_info.h	2006-08-20 14:56:22.728192788 +0200
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
--- wireless-dev.orig/net/d80211/tkip.h	2006-08-20 14:56:07.308192788 +0200
+++ wireless-dev/net/d80211/tkip.h	2006-08-20 14:56:22.728192788 +0200
@@ -10,6 +10,7 @@
 #define TKIP_H
 
 #include <linux/types.h>
+#include <linux/crypto.h>
 #include "ieee80211_key.h"
 
 u8 * ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,

--
