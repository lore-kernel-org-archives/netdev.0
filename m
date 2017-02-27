From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: smsc: epic100: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 27 Feb 2017 23:43:14 +0100
Message-ID: <1488235394-11423-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com, edumazet@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/smsc/epic100.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 5f27371..db6dcb0 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -1387,25 +1387,27 @@ static void netdev_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *
 	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
-static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct epic_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
-	rc = mii_ethtool_gset(&np->mii, cmd);
+	rc = mii_ethtool_get_link_ksettings(&np->mii, cmd);
 	spin_unlock_irq(&np->lock);
 
 	return rc;
 }
 
-static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct epic_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
-	rc = mii_ethtool_sset(&np->mii, cmd);
+	rc = mii_ethtool_set_link_ksettings(&np->mii, cmd);
 	spin_unlock_irq(&np->lock);
 
 	return rc;
@@ -1460,14 +1462,14 @@ static void ethtool_complete(struct net_device *dev)
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
-	.get_settings		= netdev_get_settings,
-	.set_settings		= netdev_set_settings,
 	.nway_reset		= netdev_nway_reset,
 	.get_link		= netdev_get_link,
 	.get_msglevel		= netdev_get_msglevel,
 	.set_msglevel		= netdev_set_msglevel,
 	.begin			= ethtool_begin,
-	.complete		= ethtool_complete
+	.complete		= ethtool_complete,
+	.get_link_ksettings	= netdev_get_link_ksettings,
+	.set_link_ksettings	= netdev_set_link_ksettings,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
