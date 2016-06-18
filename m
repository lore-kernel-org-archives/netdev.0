From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: sun4i-emac: use phy_ethtool_{get|set}_link_ksettings
Date: Sat, 18 Jun 2016 15:15:40 +0200
Message-ID: <1466255740-20999-2-git-send-email-tremyfr@gmail.com>
References: <1466255740-20999-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: maxime.ripard@free-electrons.com, wens@csie.org,
	davem@davemloft.net, hdegoede@redhat.com, mugunthanvnm@ti.com,
	a@unstable.cc, fw@strlen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466255740-20999-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c |   24 ++----------------------
 1 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 6e31cb6..6ffdff6 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -225,31 +225,11 @@ static void emac_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, dev_name(&dev->dev), sizeof(info->bus_info));
 }
 
-static int emac_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_gset(phydev, cmd);
-}
-
-static int emac_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_sset(phydev, cmd);
-}
-
 static const struct ethtool_ops emac_ethtool_ops = {
 	.get_drvinfo	= emac_get_drvinfo,
-	.get_settings	= emac_get_settings,
-	.set_settings	= emac_set_settings,
 	.get_link	= ethtool_op_get_link,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static unsigned int emac_setup(struct net_device *ndev)
-- 
1.7.4.4
