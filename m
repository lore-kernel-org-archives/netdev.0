From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 07/21] net: vxlan: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:35 +0200
Message-ID: <1439886649-24166-8-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
 <1439886649-24166-6-git-send-email-phil@nwl.cc>
 <1439886649-24166-7-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:48564 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751829AbbHRIay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:54 -0400
In-Reply-To: <1439886649-24166-7-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 06c0731..ad51dac 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2416,7 +2416,6 @@ static void vxlan_setup(struct net_device *dev)
 	dev->destructor = free_netdev;
 	SET_NETDEV_DEVTYPE(dev, &vxlan_type);
 
-	dev->tx_queue_len = 0;
 	dev->features	|= NETIF_F_LLTX;
 	dev->features	|= NETIF_F_SG | NETIF_F_HW_CSUM;
 	dev->features   |= NETIF_F_RXCSUM;
@@ -2428,7 +2427,7 @@ static void vxlan_setup(struct net_device *dev)
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
 	netif_keep_dst(dev);
-	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
 
 	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
-- 
2.1.2
