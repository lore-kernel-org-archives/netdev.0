From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 2/5] stmmac: replace hardcoded function name by __func__
Date: Thu, 10 Sep 2015 14:37:30 +0200
Message-ID: <1441888653-30535-3-git-send-email-clabbe.montjoie@gmail.com>
References: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some printing have the function name hardcoded.
It is better to use __func__ instead.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1cfce6e..b016f04 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -831,7 +831,7 @@ static int stmmac_init_phy(struct net_device *dev)
 
 		snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 			 priv->plat->phy_addr);
-		netdev_dbg(priv->dev, "stmmac_init_phy: trying to attach to %s\n",
+		netdev_dbg(priv->dev, "%s: trying to attach to %s\n", __func__,
 			   phy_id_fmt);
 
 		phydev = phy_connect(dev, phy_id_fmt, &stmmac_adjust_link,
@@ -862,8 +862,8 @@ static int stmmac_init_phy(struct net_device *dev)
 		phy_disconnect(phydev);
 		return -ENODEV;
 	}
-	netdev_dbg(priv->dev, "stmmac_init_phy: %s: attached to PHY (UID 0x%x) Link = %d\n",
-		   dev->name, phydev->phy_id, phydev->link);
+	netdev_dbg(priv->dev, "%s: %s: attached to PHY (UID 0x%x) Link = %d\n",
+		   __func__, dev->name, phydev->phy_id, phydev->link);
 
 	priv->phydev = phydev;
 
-- 
2.4.6
