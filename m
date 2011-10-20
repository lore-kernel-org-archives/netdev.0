From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 11/17] sh_eth: Don't unnecessarily reset the PHY
Date: Thu, 20 Oct 2011 17:00:18 -0400
Message-ID: <1319144425-15547-12-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Kuninori Morimoto <morimoto.kuninori@renesas.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY is already reset during driver probing, and this manual reset
afterwards will wipe out board-specific PHY fixups and driver-specific
phy->drv->config_init() register tweaks.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 drivers/net/sh_eth.c |   19 +------------------
 1 files changed, 1 insertions(+), 18 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 1c1666e..7ef4378 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1235,23 +1235,6 @@ static int sh_eth_phy_init(struct net_device *ndev)
 	return 0;
 }
 
-/* PHY control start function */
-static int sh_eth_phy_start(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-	int ret;
-
-	ret = sh_eth_phy_init(ndev);
-	if (ret)
-		return ret;
-
-	/* reset phy - this also wakes it from PDOWN */
-	phy_write(mdp->phydev, MII_BMCR, BMCR_RESET);
-	phy_start(mdp->phydev);
-
-	return 0;
-}
-
 static int sh_eth_get_settings(struct net_device *ndev,
 			struct ethtool_cmd *ecmd)
 {
@@ -1410,7 +1393,7 @@ static int sh_eth_open(struct net_device *ndev)
 		goto out_free_irq;
 
 	/* PHY control start*/
-	ret = sh_eth_phy_start(ndev);
+	ret = sh_eth_phy_init(ndev);
 	if (ret)
 		goto out_free_irq;
 
-- 
1.7.2.5
