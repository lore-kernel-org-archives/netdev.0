From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/4] d80211: better deallocation of mdev
Date: Mon,  3 Jul 2006 19:24:07 +0200 (CEST)
Message-ID: <20060703172407.BD04B483BC@silver.suse.cz>
References: <20060703192335.935001000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:2479 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751207AbWGCRWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 13:22:34 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060703192335.935001000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Master device and ieee80211_local are allocated separately now, so master
device can be freed by the same function as other virtual interfaces.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |    2 +-
 net/d80211/ieee80211_iface.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

de609aa3e039b91ebebbec45d4bddd1134a71948
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index f1e42d4..fe1003b 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4536,7 +4536,7 @@ void ieee80211_free_hw(struct net_device
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

