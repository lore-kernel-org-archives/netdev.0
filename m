From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/9] Cleanup and extension of netdev features
Date: Wed, 16 Nov 2011 18:06:26 -0500 (EST)
Message-ID: <20111116.180626.1091422475547546491.davem@davemloft.net>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
	<20111116.174936.1998571821116555319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669Ab1KPXGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 18:06:32 -0500
In-Reply-To: <20111116.174936.1998571821116555319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 16 Nov 2011 17:49:36 -0500 (EST)

> All applied, thanks a lot for doing this work.

Just FYI, I applied the following to fix the missed cases in
the infiniband layer.

--------------------
[PATCH] infiniband: Update net drivers for netdev_features_t changes.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/hw/nes/nes_nic.c       |    6 +++---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index c00d2f3..4b3fa71 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1589,7 +1589,7 @@ static const struct ethtool_ops nes_ethtool_ops = {
 	.set_pauseparam = nes_netdev_set_pauseparam,
 };
 
-static void nes_vlan_mode(struct net_device *netdev, struct nes_device *nesdev, u32 features)
+static void nes_vlan_mode(struct net_device *netdev, struct nes_device *nesdev, netdev_features_t features)
 {
 	struct nes_adapter *nesadapter = nesdev->nesadapter;
 	u32 u32temp;
@@ -1610,7 +1610,7 @@ static void nes_vlan_mode(struct net_device *netdev, struct nes_device *nesdev,
 	spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
 }
 
-static u32 nes_fix_features(struct net_device *netdev, u32 features)
+static netdev_features_t nes_fix_features(struct net_device *netdev, netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -1624,7 +1624,7 @@ static u32 nes_fix_features(struct net_device *netdev, u32 features)
 	return features;
 }
 
-static int nes_set_features(struct net_device *netdev, u32 features)
+static int nes_set_features(struct net_device *netdev, netdev_features_t features)
 {
 	struct nes_vnic *nesvnic = netdev_priv(netdev);
 	struct nes_device *nesdev = nesvnic->nesdev;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 7567b60..efd7a96 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -171,7 +171,7 @@ static int ipoib_stop(struct net_device *dev)
 	return 0;
 }
 
-static u32 ipoib_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t ipoib_fix_features(struct net_device *dev, netdev_features_t features)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-- 
1.7.6.4
