From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: sis: sis900: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 27 Feb 2017 23:17:37 +0100
Message-ID: <1488233857-24171-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: venza@brownhat.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/sis/sis900.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 19a4587..f317034 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -2035,23 +2035,23 @@ static u32 sis900_get_link(struct net_device *net_dev)
 	return mii_link_ok(&sis_priv->mii_info);
 }
 
-static int sis900_get_settings(struct net_device *net_dev,
-				struct ethtool_cmd *cmd)
+static int sis900_get_link_ksettings(struct net_device *net_dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	spin_lock_irq(&sis_priv->lock);
-	mii_ethtool_gset(&sis_priv->mii_info, cmd);
+	mii_ethtool_get_link_ksettings(&sis_priv->mii_info, cmd);
 	spin_unlock_irq(&sis_priv->lock);
 	return 0;
 }
 
-static int sis900_set_settings(struct net_device *net_dev,
-				struct ethtool_cmd *cmd)
+static int sis900_set_link_ksettings(struct net_device *net_dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	int rt;
 	spin_lock_irq(&sis_priv->lock);
-	rt = mii_ethtool_sset(&sis_priv->mii_info, cmd);
+	rt = mii_ethtool_set_link_ksettings(&sis_priv->mii_info, cmd);
 	spin_unlock_irq(&sis_priv->lock);
 	return rt;
 }
@@ -2129,11 +2129,11 @@ static void sis900_get_wol(struct net_device *net_dev, struct ethtool_wolinfo *w
 	.get_msglevel	= sis900_get_msglevel,
 	.set_msglevel	= sis900_set_msglevel,
 	.get_link	= sis900_get_link,
-	.get_settings	= sis900_get_settings,
-	.set_settings	= sis900_set_settings,
 	.nway_reset	= sis900_nway_reset,
 	.get_wol	= sis900_get_wol,
-	.set_wol	= sis900_set_wol
+	.set_wol	= sis900_set_wol,
+	.get_link_ksettings = sis900_get_link_ksettings,
+	.set_link_ksettings = sis900_set_link_ksettings,
 };
 
 /**
-- 
1.7.4.4
