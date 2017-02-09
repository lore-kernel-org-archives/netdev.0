From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: micrel: ks8851_mll: use new api ethtool_{get|set}_link_ksettings
Date: Thu,  9 Feb 2017 11:28:25 +0100
Message-ID: <1486636105-18781-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/micrel/ks8851_mll.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index db62807..7647f7b 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1311,16 +1311,18 @@ static void ks_set_msglevel(struct net_device *netdev, u32 to)
 	ks->msg_enable = to;
 }
 
-static int ks_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+static int ks_get_link_ksettings(struct net_device *netdev,
+				 struct ethtool_link_ksettings *cmd)
 {
 	struct ks_net *ks = netdev_priv(netdev);
-	return mii_ethtool_gset(&ks->mii, cmd);
+	return mii_ethtool_get_link_ksettings(&ks->mii, cmd);
 }
 
-static int ks_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+static int ks_set_link_ksettings(struct net_device *netdev,
+				 const struct ethtool_link_ksettings *cmd)
 {
 	struct ks_net *ks = netdev_priv(netdev);
-	return mii_ethtool_sset(&ks->mii, cmd);
+	return mii_ethtool_set_link_ksettings(&ks->mii, cmd);
 }
 
 static u32 ks_get_link(struct net_device *netdev)
@@ -1339,10 +1341,10 @@ static int ks_nway_reset(struct net_device *netdev)
 	.get_drvinfo	= ks_get_drvinfo,
 	.get_msglevel	= ks_get_msglevel,
 	.set_msglevel	= ks_set_msglevel,
-	.get_settings	= ks_get_settings,
-	.set_settings	= ks_set_settings,
 	.get_link	= ks_get_link,
 	.nway_reset	= ks_nway_reset,
+	.get_link_ksettings = ks_get_link_ksettings,
+	.set_link_ksettings = ks_set_link_ksettings,
 };
 
 /* MII interface controls */
-- 
1.7.4.4
