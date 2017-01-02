From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: faraday: ftmac100: use new api ethtool_{get|set}_link_ksettings
Date: Mon,  2 Jan 2017 19:53:11 +0100
Message-ID: <1483383191-30477-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, joel@jms.id.au, gwshan@linux.vnet.ibm.com,
        andrew@lunn.ch, andrew@aj.id.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/faraday/ftmac100.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index dce5f7b..c0ddbbe 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -825,16 +825,18 @@ static void ftmac100_get_drvinfo(struct net_device *netdev,
 	strlcpy(info->bus_info, dev_name(&netdev->dev), sizeof(info->bus_info));
 }
 
-static int ftmac100_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+static int ftmac100_get_link_ksettings(struct net_device *netdev,
+				       struct ethtool_link_ksettings *cmd)
 {
 	struct ftmac100 *priv = netdev_priv(netdev);
-	return mii_ethtool_gset(&priv->mii, cmd);
+	return mii_ethtool_get_link_ksettings(&priv->mii, cmd);
 }
 
-static int ftmac100_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+static int ftmac100_set_link_ksettings(struct net_device *netdev,
+				       const struct ethtool_link_ksettings *cmd)
 {
 	struct ftmac100 *priv = netdev_priv(netdev);
-	return mii_ethtool_sset(&priv->mii, cmd);
+	return mii_ethtool_set_link_ksettings(&priv->mii, cmd);
 }
 
 static int ftmac100_nway_reset(struct net_device *netdev)
@@ -850,11 +852,11 @@ static u32 ftmac100_get_link(struct net_device *netdev)
 }
 
 static const struct ethtool_ops ftmac100_ethtool_ops = {
-	.set_settings		= ftmac100_set_settings,
-	.get_settings		= ftmac100_get_settings,
 	.get_drvinfo		= ftmac100_get_drvinfo,
 	.nway_reset		= ftmac100_nway_reset,
 	.get_link		= ftmac100_get_link,
+	.get_link_ksettings	= ftmac100_get_link_ksettings,
+	.set_link_ksettings	= ftmac100_set_link_ksettings,
 };
 
 /******************************************************************************
-- 
1.7.4.4
