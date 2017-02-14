From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 6/8] net: stmmac: split the stmmac_adjust_link 10/100 case
Date: Tue, 14 Feb 2017 20:54:39 +0100
Message-ID: <20170214195441.30425-7-clabbe.montjoie@gmail.com>
References: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 10/100 case have too many ifcase.
This patch split it for removing an if.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index bebe810..3cbe096 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -721,15 +721,19 @@ static void stmmac_adjust_link(struct net_device *dev)
 					ctrl &= ~priv->hw->link.port;
 				break;
 			case 100:
+				if (priv->plat->has_gmac ||
+				    priv->plat->has_gmac4) {
+					ctrl |= priv->hw->link.port;
+					ctrl |= priv->hw->link.speed;
+				} else {
+					ctrl &= ~priv->hw->link.port;
+				}
+				break;
 			case 10:
 				if (priv->plat->has_gmac ||
 				    priv->plat->has_gmac4) {
 					ctrl |= priv->hw->link.port;
-					if (phydev->speed == SPEED_100) {
-						ctrl |= priv->hw->link.speed;
-					} else {
-						ctrl &= ~(priv->hw->link.speed);
-					}
+					ctrl &= ~(priv->hw->link.speed);
 				} else {
 					ctrl &= ~priv->hw->link.port;
 				}
-- 
2.10.2
