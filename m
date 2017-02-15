From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 5/8] net: stmmac: run stmmac_hw_fix_mac_speed when speed is valid
Date: Wed, 15 Feb 2017 10:46:42 +0100
Message-ID: <20170215094645.591-6-clabbe.montjoie@gmail.com>
References: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch mutualise a bit by running stmmac_hw_fix_mac_speed() after
the switch in case of valid speed.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index f7664b9..bebe810 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -719,7 +719,6 @@ static void stmmac_adjust_link(struct net_device *dev)
 				if (priv->plat->has_gmac ||
 				    priv->plat->has_gmac4)
 					ctrl &= ~priv->hw->link.port;
-				stmmac_hw_fix_mac_speed(priv);
 				break;
 			case 100:
 			case 10:
@@ -734,7 +733,6 @@ static void stmmac_adjust_link(struct net_device *dev)
 				} else {
 					ctrl &= ~priv->hw->link.port;
 				}
-				stmmac_hw_fix_mac_speed(priv);
 				break;
 			default:
 				netif_warn(priv, link, priv->dev,
@@ -742,7 +740,8 @@ static void stmmac_adjust_link(struct net_device *dev)
 				phydev->speed = SPEED_UNKNOWN;
 				break;
 			}
-
+			if (phydev->speed != SPEED_UNKNOWN)
+				stmmac_hw_fix_mac_speed(priv);
 			priv->speed = phydev->speed;
 		}
 
-- 
2.10.2
