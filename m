From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: micrel: ks8851: use new api ethtool_{get|set}_link_ksettings
Date: Thu,  9 Feb 2017 09:57:47 +0100
Message-ID: <1486630667-31935-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com, stephen.boyd@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/micrel/ks8851.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 955d69a..279ee46 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1086,16 +1086,18 @@ static void ks8851_set_msglevel(struct net_device *dev, u32 to)
 	ks->msg_enable = to;
 }
 
-static int ks8851_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int ks8851_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct ks8851_net *ks = netdev_priv(dev);
-	return mii_ethtool_gset(&ks->mii, cmd);
+	return mii_ethtool_get_link_ksettings(&ks->mii, cmd);
 }
 
-static int ks8851_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int ks8851_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct ks8851_net *ks = netdev_priv(dev);
-	return mii_ethtool_sset(&ks->mii, cmd);
+	return mii_ethtool_set_link_ksettings(&ks->mii, cmd);
 }
 
 static u32 ks8851_get_link(struct net_device *dev)
@@ -1251,13 +1253,13 @@ static int ks8851_get_eeprom_len(struct net_device *dev)
 	.get_drvinfo	= ks8851_get_drvinfo,
 	.get_msglevel	= ks8851_get_msglevel,
 	.set_msglevel	= ks8851_set_msglevel,
-	.get_settings	= ks8851_get_settings,
-	.set_settings	= ks8851_set_settings,
 	.get_link	= ks8851_get_link,
 	.nway_reset	= ks8851_nway_reset,
 	.get_eeprom_len	= ks8851_get_eeprom_len,
 	.get_eeprom	= ks8851_get_eeprom,
 	.set_eeprom	= ks8851_set_eeprom,
+	.get_link_ksettings = ks8851_get_link_ksettings,
+	.set_link_ksettings = ks8851_set_link_ksettings,
 };
 
 /* MII interface controls */
-- 
1.7.4.4
