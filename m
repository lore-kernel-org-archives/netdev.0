From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: hamachi: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 16 Feb 2017 22:46:14 +0100
Message-ID: <1487281574-30613-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/packetengines/hamachi.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index baff744..8b026db 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -1811,21 +1811,23 @@ static void hamachi_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *
 	strlcpy(info->bus_info, pci_name(np->pci_dev), sizeof(info->bus_info));
 }
 
-static int hamachi_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int hamachi_get_link_ksettings(struct net_device *dev,
+				      struct ethtool_link_ksettings *cmd)
 {
 	struct hamachi_private *np = netdev_priv(dev);
 	spin_lock_irq(&np->lock);
-	mii_ethtool_gset(&np->mii_if, ecmd);
+	mii_ethtool_get_link_ksettings(&np->mii_if, cmd);
 	spin_unlock_irq(&np->lock);
 	return 0;
 }
 
-static int hamachi_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int hamachi_set_link_ksettings(struct net_device *dev,
+				      const struct ethtool_link_ksettings *cmd)
 {
 	struct hamachi_private *np = netdev_priv(dev);
 	int res;
 	spin_lock_irq(&np->lock);
-	res = mii_ethtool_sset(&np->mii_if, ecmd);
+	res = mii_ethtool_set_link_ksettings(&np->mii_if, cmd);
 	spin_unlock_irq(&np->lock);
 	return res;
 }
@@ -1845,10 +1847,10 @@ static u32 hamachi_get_link(struct net_device *dev)
 static const struct ethtool_ops ethtool_ops = {
 	.begin = check_if_running,
 	.get_drvinfo = hamachi_get_drvinfo,
-	.get_settings = hamachi_get_settings,
-	.set_settings = hamachi_set_settings,
 	.nway_reset = hamachi_nway_reset,
 	.get_link = hamachi_get_link,
+	.get_link_ksettings = hamachi_get_link_ksettings,
+	.set_link_ksettings = hamachi_set_link_ksettings,
 };
 
 static const struct ethtool_ops ethtool_ops_no_mii = {
-- 
1.7.4.4
