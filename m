From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] bridge: Set vlan_features to allow offloads on vlans.
Date: Wed, 22 May 2013 11:46:30 -0400
Message-ID: <1369237590-29871-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756544Ab3EVPq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 11:46:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When vlan device is configured on top of the brige, it does
not support any offload capabilities because the bridge
device does not initiliaze vlan_fatures.  Set vlan_fatures to
be equivalent to hw_fatures.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 9673128..126f2c2 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -352,6 +352,7 @@ void br_dev_setup(struct net_device *dev)
 	dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			   NETIF_F_GSO_MASK | NETIF_F_HW_CSUM |
 			   NETIF_F_HW_VLAN_CTAG_TX;
+	dev->vlan_features = dev->hw_features;
 
 	br->dev = dev;
 	spin_lock_init(&br->lock);
-- 
1.7.7.6
