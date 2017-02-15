From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 2/8] net: stmmac: likely is useless in occasional function
Date: Wed, 15 Feb 2017 10:46:39 +0100
Message-ID: <20170215094645.591-3-clabbe.montjoie@gmail.com>
References: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The stmmac_adjust_link() function is called too rarely for having
likely() macros being useful.
Just remove likely annotation in it.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ee1dbf4..511c47c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -716,15 +716,15 @@ static void stmmac_adjust_link(struct net_device *dev)
 			new_state = 1;
 			switch (phydev->speed) {
 			case 1000:
-				if (likely(priv->plat->has_gmac ||
-					   priv->plat->has_gmac4))
+				if (priv->plat->has_gmac ||
+				    priv->plat->has_gmac4)
 					ctrl &= ~priv->hw->link.port;
 				stmmac_hw_fix_mac_speed(priv);
 				break;
 			case 100:
 			case 10:
-				if (likely(priv->plat->has_gmac ||
-					   priv->plat->has_gmac4)) {
+				if (priv->plat->has_gmac ||
+				    priv->plat->has_gmac4) {
 					ctrl |= priv->hw->link.port;
 					if (phydev->speed == SPEED_100) {
 						ctrl |= priv->hw->link.speed;
-- 
2.10.2
