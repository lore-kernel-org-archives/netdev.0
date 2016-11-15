From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 09/15] net: bcmgenet: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:38 -0800
Message-ID: <20161115180644.3941-10-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 4464bc5db934..33638dc0e104 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -971,13 +971,6 @@ static int bcmgenet_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	return phy_ethtool_set_eee(priv->phydev, e);
 }
 
-static int bcmgenet_nway_reset(struct net_device *dev)
-{
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
-	return genphy_restart_aneg(priv->phydev);
-}
-
 /* standard ethtool support functions. */
 static const struct ethtool_ops bcmgenet_ethtool_ops = {
 	.get_strings		= bcmgenet_get_strings,
@@ -991,7 +984,7 @@ static const struct ethtool_ops bcmgenet_ethtool_ops = {
 	.set_wol		= bcmgenet_set_wol,
 	.get_eee		= bcmgenet_get_eee,
 	.set_eee		= bcmgenet_set_eee,
-	.nway_reset		= bcmgenet_nway_reset,
+	.nway_reset		= phy_ethtool_nway_reset,
 	.get_coalesce		= bcmgenet_get_coalesce,
 	.set_coalesce		= bcmgenet_set_coalesce,
 	.get_link_ksettings	= bcmgenet_get_link_ksettings,
-- 
2.9.3
