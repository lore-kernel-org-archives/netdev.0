From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH] net: stmmac: remove unneeded phy_iface variable
Date: Wed,  4 Nov 2015 21:08:12 +0100
Message-ID: <1446667692-6182-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable phy_iface is double-initialized and finally is not necessary
at all.

Reported-by: coverity (CID 1271141)
Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 11baa4b..26a11b7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -354,11 +354,9 @@ static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 
 static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 {
-	int phy_iface = phy_iface = bsp_priv->phy_iface;
-
 	if (enable) {
 		if (!bsp_priv->clk_enabled) {
-			if (phy_iface == PHY_INTERFACE_MODE_RMII) {
+			if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII) {
 				if (!IS_ERR(bsp_priv->mac_clk_rx))
 					clk_prepare_enable(
 						bsp_priv->mac_clk_rx);
@@ -390,7 +388,7 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 		}
 	} else {
 		if (bsp_priv->clk_enabled) {
-			if (phy_iface == PHY_INTERFACE_MODE_RMII) {
+			if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII) {
 				if (!IS_ERR(bsp_priv->mac_clk_rx))
 					clk_disable_unprepare(
 						bsp_priv->mac_clk_rx);
-- 
2.4.10
