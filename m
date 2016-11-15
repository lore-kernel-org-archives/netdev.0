From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 11/15] net: fec: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:40 -0800
Message-ID: <20161115180644.3941-12-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 01aebc0084a9..1aabe4bcc8ea 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2344,16 +2344,6 @@ static int fec_enet_get_sset_count(struct net_device *dev, int sset)
 }
 #endif /* !defined(CONFIG_M5272) */
 
-static int fec_enet_nway_reset(struct net_device *dev)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return genphy_restart_aneg(phydev);
-}
-
 /* ITR clock source is enet system clock (clk_ahb).
  * TCTT unit is cycle_ns * 64 cycle
  * So, the ICTT value = X us / (cycle_ns * 64)
@@ -2553,7 +2543,7 @@ static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_drvinfo		= fec_enet_get_drvinfo,
 	.get_regs_len		= fec_enet_get_regs_len,
 	.get_regs		= fec_enet_get_regs,
-	.nway_reset		= fec_enet_nway_reset,
+	.nway_reset		= phy_ethtool_nway_reset,
 	.get_link		= ethtool_op_get_link,
 	.get_coalesce		= fec_enet_get_coalesce,
 	.set_coalesce		= fec_enet_set_coalesce,
-- 
2.9.3
