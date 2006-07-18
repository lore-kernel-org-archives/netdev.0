From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 7/9] d80211: SET_NETDEV_DEV for non-master devices
Date: Tue, 18 Jul 2006 17:45:28 +0200 (CEST)
Message-ID: <20060718154528.199A0483BC@silver.suse.cz>
References: <20060718174442.485760904.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41097 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932296AbWGRPnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:43:40 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060718174442.485760904.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds /sys/class/net/*/device symlinks for non-master (wlan* and wmgmt*)
devices.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_iface.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

80f18b79eacc07319afe473023a5358cfbc11ae6
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index f64b4de..fa3d9e2 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -76,6 +76,7 @@ int ieee80211_if_add(struct net_device *
 	ndev->mem_start = dev->mem_start;
 	ndev->mem_end = dev->mem_end;
 	ndev->flags = dev->flags & IFF_MULTICAST;
+	SET_NETDEV_DEV(ndev, dev->class_dev.dev);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	sdata->type = IEEE80211_IF_TYPE_AP;
@@ -130,6 +131,7 @@ int ieee80211_if_add_mgmt(struct net_dev
 	ndev->irq = dev->irq;
 	ndev->mem_start = dev->mem_start;
 	ndev->mem_end = dev->mem_end;
+	SET_NETDEV_DEV(ndev, dev->class_dev.dev);
 
 	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	nsdata->type = IEEE80211_IF_TYPE_MGMT;
-- 
1.3.0

