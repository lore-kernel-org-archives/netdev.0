From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 04/15] net: mv643xx_eth: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:33 -0800
Message-ID: <20161115180644.3941-5-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 81b08d71c0f8..5f62c3d70df9 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1639,14 +1639,6 @@ static void mv643xx_eth_get_drvinfo(struct net_device *dev,
 	strlcpy(drvinfo->bus_info, "platform", sizeof(drvinfo->bus_info));
 }
 
-static int mv643xx_eth_nway_reset(struct net_device *dev)
-{
-	if (!dev->phydev)
-		return -EINVAL;
-
-	return genphy_restart_aneg(dev->phydev);
-}
-
 static int
 mv643xx_eth_get_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 {
@@ -1770,7 +1762,7 @@ static int mv643xx_eth_get_sset_count(struct net_device *dev, int sset)
 
 static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.get_drvinfo		= mv643xx_eth_get_drvinfo,
-	.nway_reset		= mv643xx_eth_nway_reset,
+	.nway_reset		= phy_ethtool_nway_reset,
 	.get_link		= ethtool_op_get_link,
 	.get_coalesce		= mv643xx_eth_get_coalesce,
 	.set_coalesce		= mv643xx_eth_set_coalesce,
-- 
2.9.3
