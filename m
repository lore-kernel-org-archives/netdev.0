From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 21/21] d80211: add ieee80211_stop_queues()
Date: Wed, 23 Aug 2006 21:24:30 +0200 (CEST)
Message-ID: <20060823192430.8B815483BA@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:30928 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965136AbWHWTYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:30 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>

Add ieee80211_stop_queues() to stop all queues
with a single call.
I will submit a patch for bcm43xx to use this function
as soon as this got merged.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h   |    9 +++++++++
 net/d80211/ieee80211.c |   10 ++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

414f928269a9d41642e85abc8fe47e5bc90eed6b
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 23839b4..42fdbf7 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -830,6 +830,15 @@ void ieee80211_stop_queue(struct net_dev
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
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ad37015..e72721f 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4705,6 +4705,16 @@ void ieee80211_start_queues(struct net_d
 }
 EXPORT_SYMBOL(ieee80211_start_queues);
 
+void ieee80211_stop_queues(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	int i;
+
+	for (i = 0; i < local->hw->queues; i++)
+		ieee80211_stop_queue(dev, i);
+}
+EXPORT_SYMBOL(ieee80211_stop_queues);
+
 void * ieee80211_dev_hw_data(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-- 
1.3.0

