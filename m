From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: sgi: ioc3-eth: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 26 Feb 2017 22:48:59 +0100
Message-ID: <1488145739-30614-1-git-send-email-tremyfr@gmail.com>
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: ralf@linux-mips.org, davem@davemloft.net
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/sgi/ioc3-eth.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 57e6cef..52ead55 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -1558,25 +1558,27 @@ static void ioc3_get_drvinfo (struct net_device *dev,
 	strlcpy(info->bus_info, pci_name(ip->pdev), sizeof(info->bus_info));
 }
 
-static int ioc3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int ioc3_get_link_ksettings(struct net_device *dev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct ioc3_private *ip = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&ip->ioc3_lock);
-	rc = mii_ethtool_gset(&ip->mii, cmd);
+	rc = mii_ethtool_get_link_ksettings(&ip->mii, cmd);
 	spin_unlock_irq(&ip->ioc3_lock);
 
 	return rc;
 }
 
-static int ioc3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int ioc3_set_link_ksettings(struct net_device *dev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	struct ioc3_private *ip = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&ip->ioc3_lock);
-	rc = mii_ethtool_sset(&ip->mii, cmd);
+	rc = mii_ethtool_set_link_ksettings(&ip->mii, cmd);
 	spin_unlock_irq(&ip->ioc3_lock);
 
 	return rc;
@@ -1608,10 +1610,10 @@ static u32 ioc3_get_link(struct net_device *dev)
 
 static const struct ethtool_ops ioc3_ethtool_ops = {
 	.get_drvinfo		= ioc3_get_drvinfo,
-	.get_settings		= ioc3_get_settings,
-	.set_settings		= ioc3_set_settings,
 	.nway_reset		= ioc3_nway_reset,
 	.get_link		= ioc3_get_link,
+	.get_link_ksettings	= ioc3_get_link_ksettings,
+	.set_link_ksettings	= ioc3_set_link_ksettings,
 };
 
 static int ioc3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
