From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH] d80211: SET_NETDEV_DEV for non-master devices
Date: Wed, 12 Jul 2006 19:01:20 +0200
Message-ID: <20060712190120.7c909ac7@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:64666 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751458AbWGLRBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 13:01:22 -0400
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds /sys/class/net/*/device symlinks for non-master (wlan* and wmgmt*)
devices.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211_iface.c |    2 ++
 1 files changed, 2 insertions(+)

--- dscape.orig/net/d80211/ieee80211_iface.c
+++ dscape/net/d80211/ieee80211_iface.c
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
Jiri Benc
SUSE Labs
