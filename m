From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 13:44:20 +0200
Message-ID: <200608231344.20438.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:14045
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932428AbWHWLpo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 07:45:44 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ieee80211_stop_queues() to stop all queues
with a single call.
I will submit a patch for bcm43xx to use this function
as soon as this got merged.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h	2006-08-19 18:26:05.000000000 +0200
+++ wireless-dev/include/net/d80211.h	2006-08-23 13:38:41.000000000 +0200
@@ -826,6 +826,15 @@
 void ieee80211_start_queues(struct net_device *dev);
 
 /**
+ * ieee80211_stop_queues - stop all queues
+ * @dev: pointer to $struct net_device as obtained from
+ *       ieee80211_alloc_hw().
+ *
+ * Drivers should use this function instead of netif_stop_queue.
+ */
+void ieee80211_stop_queues(struct net_device *dev);
+
+/**
  * ieee80211_get_mc_list_item - iteration over items in multicast list
  * @dev: pointer to &struct net_device as obtained from
  *	ieee80211_alloc_hw().
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-19 18:26:05.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-23 13:41:34.000000000 +0200
@@ -4690,6 +4690,15 @@
 		clear_bit(IEEE80211_LINK_STATE_XOFF, &local->state[i]);
 }
 
+void ieee80211_stop_queues(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	int i;
+
+	for (i = 0; i < local->hw->queues; i++)
+		ieee80211_stop_queue(dev, i);
+}
+
 void * ieee80211_dev_hw_data(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
@@ -4819,6 +4828,7 @@
 EXPORT_SYMBOL(ieee80211_wake_queue);
 EXPORT_SYMBOL(ieee80211_stop_queue);
 EXPORT_SYMBOL(ieee80211_start_queues);
+EXPORT_SYMBOL(ieee80211_stop_queues);
 EXPORT_SYMBOL(ieee80211_dev_hw_data);
 EXPORT_SYMBOL(ieee80211_dev_stats);
 EXPORT_SYMBOL(ieee80211_get_hw_conf);

-- 
Greetings Michael.
