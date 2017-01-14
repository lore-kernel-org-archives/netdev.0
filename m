From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: korina: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 14 Jan 2017 12:33:19 +0100
Message-ID: <1484393599-1547-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/korina.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 8037426..3e415b8 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -695,25 +695,27 @@ static void netdev_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, lp->dev->name, sizeof(info->bus_info));
 }
 
-static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct korina_private *lp = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&lp->lock);
-	rc = mii_ethtool_gset(&lp->mii_if, cmd);
+	rc = mii_ethtool_get_link_ksettings(&lp->mii_if, cmd);
 	spin_unlock_irq(&lp->lock);
 
 	return rc;
 }
 
-static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct korina_private *lp = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&lp->lock);
-	rc = mii_ethtool_sset(&lp->mii_if, cmd);
+	rc = mii_ethtool_set_link_ksettings(&lp->mii_if, cmd);
 	spin_unlock_irq(&lp->lock);
 	korina_set_carrier(&lp->mii_if);
 
@@ -729,9 +731,9 @@ static u32 netdev_get_link(struct net_device *dev)
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo            = netdev_get_drvinfo,
-	.get_settings           = netdev_get_settings,
-	.set_settings           = netdev_set_settings,
 	.get_link               = netdev_get_link,
+	.get_link_ksettings     = netdev_get_link_ksettings,
+	.set_link_ksettings     = netdev_set_link_ksettings,
 };
 
 static int korina_alloc_ring(struct net_device *dev)
-- 
1.7.4.4
