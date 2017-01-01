From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: dlink: sundance: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  1 Jan 2017 20:52:12 +0100
Message-ID: <1483300332-22834-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: kda@linux-powerpc.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/dlink/sundance.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 2e5b667..2704bcf 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -1664,21 +1664,23 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
-static int get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int get_link_ksettings(struct net_device *dev,
+			      struct ethtool_link_ksettings *cmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	spin_lock_irq(&np->lock);
-	mii_ethtool_gset(&np->mii_if, ecmd);
+	mii_ethtool_get_link_ksettings(&np->mii_if, cmd);
 	spin_unlock_irq(&np->lock);
 	return 0;
 }
 
-static int set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int set_link_ksettings(struct net_device *dev,
+			      const struct ethtool_link_ksettings *cmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int res;
 	spin_lock_irq(&np->lock);
-	res = mii_ethtool_sset(&np->mii_if, ecmd);
+	res = mii_ethtool_set_link_ksettings(&np->mii_if, cmd);
 	spin_unlock_irq(&np->lock);
 	return res;
 }
@@ -1800,8 +1802,6 @@ static int sundance_set_wol(struct net_device *dev,
 static const struct ethtool_ops ethtool_ops = {
 	.begin = check_if_running,
 	.get_drvinfo = get_drvinfo,
-	.get_settings = get_settings,
-	.set_settings = set_settings,
 	.nway_reset = nway_reset,
 	.get_link = get_link,
 	.get_wol = sundance_get_wol,
@@ -1811,6 +1811,8 @@ static int sundance_set_wol(struct net_device *dev,
 	.get_strings = get_strings,
 	.get_sset_count = get_sset_count,
 	.get_ethtool_stats = get_ethtool_stats,
+	.get_link_ksettings = get_link_ksettings,
+	.set_link_ksettings = set_link_ksettings,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
