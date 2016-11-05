From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: adaptec: starfire: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  5 Nov 2016 14:05:39 +0100
Message-ID: <1478351139-1720-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: ionut@badula.org, davem@davemloft.net, mugunthanvnm@ti.com,
        a@unstable.cc, fw@strlen.de, jarod@redhat.com,
        javier@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/adaptec/starfire.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 4a9a16e..3aaad33 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -1816,21 +1816,23 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
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
 	check_duplex(dev);
 	return res;
@@ -1861,12 +1863,12 @@ static void set_msglevel(struct net_device *dev, u32 val)
 static const struct ethtool_ops ethtool_ops = {
 	.begin = check_if_running,
 	.get_drvinfo = get_drvinfo,
-	.get_settings = get_settings,
-	.set_settings = set_settings,
 	.nway_reset = nway_reset,
 	.get_link = get_link,
 	.get_msglevel = get_msglevel,
 	.set_msglevel = set_msglevel,
+	.get_link_ksettings = get_link_ksettings,
+	.set_link_ksettings = set_link_ksettings,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
