From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] d80211: fix some 0 vs. NULL comparisons
Date: Mon, 14 Aug 2006 10:13:44 +0200
Message-ID: <44E030B8.2000600@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:32962 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751930AbWHNINs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 04:13:48 -0400
To: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	Jiri Benc <jbenc@suse.cz>
In-Reply-To: <44E02F41.2060300@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes places where pointers are compared against 0 and 
unifies it a bit.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211_scan.c    2006-08-12 
10:11:21.069644280 +0200
+++ wireless-dev/net/d80211/ieee80211_scan.c    2006-08-12 
10:11:44.619644280 +0200
@@ -117,7 +117,7 @@ static void ieee80211_scan_start(struct
     struct ieee80211_channel *chan = NULL;
     int ret;
 
-    if (local->hw->passive_scan == 0) {
+    if (local->hw->passive_scan == NULL) {
         printk(KERN_DEBUG "%s: Scan handler called, yet the hardware "
                "does not support passive scanning. Disabled.\n",
                dev->name);
@@ -293,7 +293,7 @@ void ieee80211_init_scan(struct net_devi
     struct rate_control_extra extra;
 
     /* Only initialize passive scanning if the hardware supports it */
-    if (!local->hw->passive_scan) {
+    if (local->hw->passive_scan == NULL) {
         local->scan.skb = NULL;
         memset(&local->scan.tx_control, 0,
                sizeof(local->scan.tx_control));
@@ -344,7 +344,7 @@ void ieee80211_stop_scan(struct net_devi
 {
     struct ieee80211_local *local = dev->ieee80211_ptr;
 
-    if (local->hw->passive_scan != 0) {
+    if (local->hw->passive_scan != NULL) {
         del_timer_sync(&local->scan.timer);
         dev_kfree_skb(local->scan.skb);
         local->scan.skb = NULL;

