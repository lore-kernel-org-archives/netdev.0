From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: dec: winbond-840: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  1 Jan 2017 20:47:01 +0100
Message-ID: <1483300021-21783-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/dec/tulip/winbond-840.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index bc9bf88..d1f2f3c 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -1391,25 +1391,27 @@ static void netdev_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *
 	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
-static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
-	rc = mii_ethtool_gset(&np->mii_if, cmd);
+	rc = mii_ethtool_get_link_ksettings(&np->mii_if, cmd);
 	spin_unlock_irq(&np->lock);
 
 	return rc;
 }
 
-static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
-	rc = mii_ethtool_sset(&np->mii_if, cmd);
+	rc = mii_ethtool_set_link_ksettings(&np->mii_if, cmd);
 	spin_unlock_irq(&np->lock);
 
 	return rc;
@@ -1439,12 +1441,12 @@ static void netdev_set_msglevel(struct net_device *dev, u32 value)
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
-	.get_settings		= netdev_get_settings,
-	.set_settings		= netdev_set_settings,
 	.nway_reset		= netdev_nway_reset,
 	.get_link		= netdev_get_link,
 	.get_msglevel		= netdev_get_msglevel,
 	.set_msglevel		= netdev_set_msglevel,
+	.get_link_ksettings	= netdev_get_link_ksettings,
+	.set_link_ksettings	= netdev_set_link_ksettings,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
