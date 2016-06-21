From: Xing Zheng <zhengxing@rock-chips.com>
Subject: [PATCH v2] net: stmmac: dwmac-rk: add rk3228-specific data
Date: Tue, 21 Jun 2016 20:33:28 +0800
Message-ID: <1466512409-18855-1-git-send-email-zhengxing@rock-chips.com>
Cc: linux-rockchip@lists.infradead.org, roger.chen@rock-chips.com,
	Xing Zheng <zhengxing@rock-chips.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular1.263xmail.com ([211.150.99.134]:43637 "EHLO
	regular1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbcFUMdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 08:33:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add constants and callback functions for the dwmac on rk3228/rk3229 socs.
As can be seen, the base structure is the same, only registers and the
bits in them moved slightly.

Signed-off-by: Xing Zheng <zhengxing@rock-chips.com>
---

Changes in v2:
- the "rk322x" is not clear to SoC decription, rename it to "rk3228"

 .../devicetree/bindings/net/rockchip-dwmac.txt     |    3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     |  117 ++++++++++++++++++++
 2 files changed, 119 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
index 93eac7c..cccd945 100644
--- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
@@ -3,7 +3,8 @@ Rockchip SoC RK3288 10/100/1000 Ethernet driver(GMAC)
 The device node has following properties.
 
 Required properties:
- - compatible: Can be one of "rockchip,rk3288-gmac", "rockchip,rk3368-gmac"
+ - compatible: Can be one of "rockchip,rk3228-gmac", "rockchip,rk3288-gmac",
+                             "rockchip,rk3368-gmac"
  - reg: addresses and length of the register sets for the device.
  - interrupts: Should contain the GMAC interrupts.
  - interrupt-names: Should contain the interrupt names "macirq".
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 0cd3ecf..25eb797 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -72,6 +72,122 @@ struct rk_priv_data {
 #define GRF_BIT(nr)	(BIT(nr) | BIT(nr+16))
 #define GRF_CLR_BIT(nr)	(BIT(nr+16))
 
+#define RK3228_GRF_MAC_CON0	0x0900
+#define RK3228_GRF_MAC_CON1	0x0904
+
+/* RK3228_GRF_MAC_CON0 */
+#define RK3228_GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 7)
+#define RK3228_GMAC_CLK_TX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 0)
+
+/* RK3228_GRF_MAC_CON1 */
+#define RK3228_GMAC_PHY_INTF_SEL_RGMII	\
+		(GRF_BIT(4) | GRF_CLR_BIT(5) | GRF_CLR_BIT(6))
+#define RK3228_GMAC_PHY_INTF_SEL_RMII	\
+		(GRF_CLR_BIT(4) | GRF_CLR_BIT(5) | GRF_BIT(6))
+#define RK3228_GMAC_FLOW_CTRL		GRF_BIT(3)
+#define RK3228_GMAC_FLOW_CTRL_CLR	GRF_CLR_BIT(3)
+#define RK3228_GMAC_SPEED_10M		GRF_CLR_BIT(2)
+#define RK3228_GMAC_SPEED_100M		GRF_BIT(2)
+#define RK3228_GMAC_RMII_CLK_25M	GRF_BIT(7)
+#define RK3228_GMAC_RMII_CLK_2_5M	GRF_CLR_BIT(7)
+#define RK3228_GMAC_CLK_125M		(GRF_CLR_BIT(8) | GRF_CLR_BIT(9))
+#define RK3228_GMAC_CLK_25M		(GRF_BIT(8) | GRF_BIT(9))
+#define RK3228_GMAC_CLK_2_5M		(GRF_CLR_BIT(8) | GRF_BIT(9))
+#define RK3228_GMAC_RMII_MODE		GRF_BIT(10)
+#define RK3228_GMAC_RMII_MODE_CLR	GRF_CLR_BIT(10)
+#define RK3228_GMAC_TXCLK_DLY_ENABLE	GRF_BIT(0)
+#define RK3228_GMAC_TXCLK_DLY_DISABLE	GRF_CLR_BIT(0)
+#define RK3228_GMAC_RXCLK_DLY_ENABLE	GRF_BIT(1)
+#define RK3228_GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(1)
+
+static void rk3228_set_to_rgmii(struct rk_priv_data *bsp_priv,
+				int tx_delay, int rx_delay)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON1,
+		     RK3228_GMAC_PHY_INTF_SEL_RGMII |
+		     RK3228_GMAC_RMII_MODE_CLR |
+		     RK3228_GMAC_RXCLK_DLY_ENABLE |
+		     RK3228_GMAC_TXCLK_DLY_ENABLE);
+
+	regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON0,
+		     RK3228_GMAC_CLK_RX_DL_CFG(rx_delay) |
+		     RK3228_GMAC_CLK_TX_DL_CFG(tx_delay));
+}
+
+static void rk3228_set_to_rmii(struct rk_priv_data *bsp_priv)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON1,
+		     RK3228_GMAC_PHY_INTF_SEL_RMII |
+		     RK3228_GMAC_RMII_MODE);
+
+	/* set MAC to RMII mode */
+	regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON1, GRF_BIT(11));
+}
+
+static void rk3228_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	if (speed == 10)
+		regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON1,
+			     RK3228_GMAC_CLK_2_5M);
+	else if (speed == 100)
+		regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON1,
+			     RK3228_GMAC_CLK_25M);
+	else if (speed == 1000)
+		regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON1,
+			     RK3228_GMAC_CLK_125M);
+	else
+		dev_err(dev, "unknown speed value for RGMII! speed=%d", speed);
+}
+
+static void rk3228_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	if (speed == 10)
+		regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON1,
+			     RK3228_GMAC_RMII_CLK_2_5M |
+			     RK3228_GMAC_SPEED_10M);
+	else if (speed == 100)
+		regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON1,
+			     RK3228_GMAC_RMII_CLK_25M |
+			     RK3228_GMAC_SPEED_100M);
+	else
+		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
+}
+
+static const struct rk_gmac_ops rk3228_ops = {
+	.set_to_rgmii = rk3228_set_to_rgmii,
+	.set_to_rmii = rk3228_set_to_rmii,
+	.set_rgmii_speed = rk3228_set_rgmii_speed,
+	.set_rmii_speed = rk3228_set_rmii_speed,
+};
+
 #define RK3288_GRF_SOC_CON1	0x0248
 #define RK3288_GRF_SOC_CON3	0x0250
 
@@ -604,6 +720,7 @@ static int rk_gmac_probe(struct platform_device *pdev)
 }
 
 static const struct of_device_id rk_gmac_dwmac_match[] = {
+	{ .compatible = "rockchip,rk3228-gmac", .data = &rk3228_ops },
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_ops },
 	{ .compatible = "rockchip,rk3368-gmac", .data = &rk3368_ops },
 	{ }
-- 
1.7.9.5
