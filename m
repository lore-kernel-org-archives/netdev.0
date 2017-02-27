From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: sis: sis190: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 27 Feb 2017 23:06:41 +0100
Message-ID: <1488233201-9815-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: romieu@fr.zoreil.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/sis/sis190.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 210e35d..02da106 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1734,18 +1734,20 @@ static void sis190_set_speed_auto(struct net_device *dev)
 		   BMCR_ANENABLE | BMCR_ANRESTART | BMCR_RESET);
 }
 
-static int sis190_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int sis190_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct sis190_private *tp = netdev_priv(dev);
 
-	return mii_ethtool_gset(&tp->mii_if, cmd);
+	return mii_ethtool_get_link_ksettings(&tp->mii_if, cmd);
 }
 
-static int sis190_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int sis190_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct sis190_private *tp = netdev_priv(dev);
 
-	return mii_ethtool_sset(&tp->mii_if, cmd);
+	return mii_ethtool_set_link_ksettings(&tp->mii_if, cmd);
 }
 
 static void sis190_get_drvinfo(struct net_device *dev,
@@ -1797,8 +1799,6 @@ static void sis190_set_msglevel(struct net_device *dev, u32 value)
 }
 
 static const struct ethtool_ops sis190_ethtool_ops = {
-	.get_settings	= sis190_get_settings,
-	.set_settings	= sis190_set_settings,
 	.get_drvinfo	= sis190_get_drvinfo,
 	.get_regs_len	= sis190_get_regs_len,
 	.get_regs	= sis190_get_regs,
@@ -1806,6 +1806,8 @@ static void sis190_set_msglevel(struct net_device *dev, u32 value)
 	.get_msglevel	= sis190_get_msglevel,
 	.set_msglevel	= sis190_set_msglevel,
 	.nway_reset	= sis190_nway_reset,
+	.get_link_ksettings = sis190_get_link_ksettings,
+	.set_link_ksettings = sis190_set_link_ksettings,
 };
 
 static int sis190_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-- 
1.7.4.4
