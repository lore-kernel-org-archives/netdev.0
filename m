From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 05/20] net-bridge: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:10 -0700
Message-ID: <1302050665-10460-6-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:53999 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab1DFAow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:52 -0400
In-Reply-To: <1302050665-10460-5-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/bridge/br_device.c |    2 +-
 net/bridge/br_if.c     |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 45cfd54..e509040 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -387,7 +387,7 @@ void br_dev_setup(struct net_device *dev)
 	dev->tx_queue_len = 0;
 	dev->priv_flags = IFF_EBRIDGE;
 
-	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
+	dev->legacy_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX |
 			NETIF_F_NETNS_LOCAL | NETIF_F_GSO | NETIF_F_HW_VLAN_TX;
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 7f5379c..17d94b0 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -304,11 +304,11 @@ void br_features_recompute(struct net_bridge *br)
 
 	list_for_each_entry(p, &br->port_list, list) {
 		features = netdev_increment_features(features,
-						     p->dev->features, mask);
+						     p->dev->legacy_features, mask);
 	}
 
 done:
-	br->dev->features = netdev_fix_features(br->dev, features);
+	br->dev->legacy_features = netdev_fix_features(br->dev, features);
 }
 
 /* called with RTNL */
-- 
1.7.3.1

