From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: ftgmac100: use phy_ethtool_{get|set}_link_ksettings
Date: Mon, 16 May 2016 01:35:14 +0200
Message-ID: <1463355314-20889-2-git-send-email-tremyfr@gmail.com>
References: <1463355314-20889-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: andrew@lunn.ch, davem@davemloft.net, f.fainelli@gmail.com,
	linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463355314-20889-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c |   16 ++--------------
 1 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 9cc23c3..e7cf313 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -937,23 +937,11 @@ static void ftgmac100_get_drvinfo(struct net_device *netdev,
 	strlcpy(info->bus_info, dev_name(&netdev->dev), sizeof(info->bus_info));
 }
 
-static int ftgmac100_get_settings(struct net_device *netdev,
-				  struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_gset(netdev->phydev, cmd);
-}
-
-static int ftgmac100_set_settings(struct net_device *netdev,
-				  struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_sset(netdev->phydev, cmd);
-}
-
 static const struct ethtool_ops ftgmac100_ethtool_ops = {
-	.set_settings		= ftgmac100_set_settings,
-	.get_settings		= ftgmac100_get_settings,
 	.get_drvinfo		= ftgmac100_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
+	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
+	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
 };
 
 /******************************************************************************
-- 
1.7.4.4
