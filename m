From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v5 07/11] net: stmmac: dwmac-rk: Add integrated PHY support for rk3228
Date: Thu, 10 Aug 2017 22:00:25 +0800
Message-ID: <1502373625-2665-1-git-send-email-david.wu@rock-chips.com>
References: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is only one mac controller in rk3228, which could connect to
external PHY or integrated PHY, use the grf_com_mux bit15 to route
external/integrated PHY.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 9019917..b6db3ff 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -86,6 +86,8 @@ struct rk_priv_data {
 #define RK3228_GRF_MAC_CON0	0x0900
 #define RK3228_GRF_MAC_CON1	0x0904
 
+#define RK3228_GRF_CON_MUX	0x50
+
 /* RK3228_GRF_MAC_CON0 */
 #define RK3228_GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 7)
 #define RK3228_GMAC_CLK_TX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 0)
@@ -111,6 +113,9 @@ struct rk_priv_data {
 #define RK3228_GMAC_RXCLK_DLY_ENABLE	GRF_BIT(1)
 #define RK3228_GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(1)
 
+/* RK3228_GRF_COM_MUX */
+#define RK3228_GRF_CON_MUX_GMAC_INTEGRATED_PHY	GRF_BIT(15)
+
 static void rk3228_set_to_rgmii(struct rk_priv_data *bsp_priv,
 				int tx_delay, int rx_delay)
 {
@@ -191,11 +196,18 @@ static void rk3228_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
 }
 
+static void rk3228_integrated_phy_powerup(struct rk_priv_data *priv)
+{
+	regmap_write(priv->grf, RK3228_GRF_CON_MUX,
+		     RK3228_GRF_CON_MUX_GMAC_INTEGRATED_PHY);
+}
+
 static const struct rk_gmac_ops rk3228_ops = {
 	.set_to_rgmii = rk3228_set_to_rgmii,
 	.set_to_rmii = rk3228_set_to_rmii,
 	.set_rgmii_speed = rk3228_set_rgmii_speed,
 	.set_rmii_speed = rk3228_set_rmii_speed,
+	.integrated_phy_powerup =  rk3228_integrated_phy_powerup,
 };
 
 #define RK3288_GRF_SOC_CON1	0x0248
-- 
1.9.1
