From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/9] d80211: better deallocation of mdev
Date: Tue, 18 Jul 2006 17:45:23 +0200 (CEST)
Message-ID: <20060718154523.E380E483BC@silver.suse.cz>
References: <20060718174442.485760904.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:40329 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932291AbWGRPng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:43:36 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060718174442.485760904.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Master device and ieee80211_local are allocated separately now, so master
device can be freed by the same function as other virtual interfaces.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |    2 +-
 net/d80211/ieee80211_iface.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

603ee5045dad050a66b94a847cd5385fc7678ce9
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 549c8a4..3d7091a 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4534,7 +4534,7 @@ void ieee80211_free_hw(struct net_device
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 
-	free_netdev(dev);
+	ieee80211_if_free(dev);
 	ieee80211_dev_free(local);
 }
 
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 5abd713..566bb36 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -337,7 +337,8 @@ void ieee80211_if_free(struct net_device
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 
-	BUG_ON(dev == local->mdev || dev == local->apdev);
+	/* local->apdev must be NULL when freeing management interface */
+	BUG_ON(dev == local->apdev);
 	free_netdev(dev);
 }
 
-- 
1.3.0

