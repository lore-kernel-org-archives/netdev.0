From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 4/8] net: stmmac: set speed at SPEED_UNKNOWN in case of broken speed
Date: Wed, 15 Feb 2017 10:46:41 +0100
Message-ID: <20170215094645.591-5-clabbe.montjoie@gmail.com>
References: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of invalid speed given, stmmac_adjust_link() still record it as
current speed.
This patch modify the default case to set speed as SPEED_UNKNOWN if not
10/100/1000.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a87071d..f7664b9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -739,6 +739,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 			default:
 				netif_warn(priv, link, priv->dev,
 					   "broken speed: %d\n", phydev->speed);
+				phydev->speed = SPEED_UNKNOWN;
 				break;
 			}
 
-- 
2.10.2
