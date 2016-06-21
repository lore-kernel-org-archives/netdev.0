From: Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH] net: stmmac: dwmac-rk: add rk322x-specific data
Date: Tue, 21 Jun 2016 15:13:55 +0800
Message-ID: <1466493235-17789-1-git-send-email-zhengxing@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
 Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
 Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
To: heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Add constants and callback functions for the dwmac on rk322x socs.
As can be seen, the base structure is the same, only registers and
the bits in them moved slightly.

Signed-off-by: Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---

 .../devicetree/bindings/net/rockchip-dwmac.txt     |    3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     |  117 ++++++++++++++++++++
 2 files changed, 119 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
index 93eac7c..5040ed4 100644
--- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
@@ -3,7 +3,8 @@ Rockchip SoC RK3288 10/100/1000 Ethernet driver(GMAC)
 The device node has following properties.
 
 Required properties:
- - compatible: Can be one of "rockchip,rk3288-gmac", "rockchip,rk3368-gmac"
+ - compatible: Can be one of "rockchip,rk322x-gmac", "rockchip,rk3288-gmac",
+                             "rockchip,rk3368-gmac"
  - reg: addresses and length of the register sets for the device.
  - interrupts: Should contain the GMAC interrupts.
  - interrupt-names: Should contain the interrupt names "macirq".
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 0cd3ecf..7f045db 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -72,6 +72,122 @@ struct rk_priv_data {
 #define GRF_BIT(nr)	(BIT(nr) | BIT(nr+16))
 #define GRF_CLR_BIT(nr)	(BIT(nr+16))
 
+#define RK322X_GRF_MAC_CON0	0x0900
+#define RK322X_GRF_MAC_CON1	0x0904
+
+/* RK322X_GRF_MAC_CON0 */
+#define RK322X_GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 7)
+#define RK322X_GMAC_CLK_TX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 0)
+
+/* RK322X_GRF_MAC_CON1 */
+#define RK322X_GMAC_PHY_INTF_SEL_RGMII	\
+		(GRF_BIT(4) | GRF_CLR_BIT(5) | GRF_CLR_BIT(6))
+#define RK322X_GMAC_PHY_INTF_SEL_RMII	\
+		(GRF_CLR_BIT(4) | GRF_CLR_BIT(5) | GRF_BIT(6))
+#define RK322X_GMAC_FLOW_CTRL		GRF_BIT(3)
+#define RK322X_GMAC_FLOW_CTRL_CLR	GRF_CLR_BIT(3)
+#define RK322X_GMAC_SPEED_10M		GRF_CLR_BIT(2)
+#define RK322X_GMAC_SPEED_100M		GRF_BIT(2)
+#define RK322X_GMAC_RMII_CLK_25M	GRF_BIT(7)
+#define RK322X_GMAC_RMII_CLK_2_5M	GRF_CLR_BIT(7)
+#define RK322X_GMAC_CLK_125M		(GRF_CLR_BIT(8) | GRF_CLR_BIT(9))
+#define RK322X_GMAC_CLK_25M		(GRF_BIT(8) | GRF_BIT(9))
+#define RK322X_GMAC_CLK_2_5M		(GRF_CLR_BIT(8) | GRF_BIT(9))
+#define RK322X_GMAC_RMII_MODE		GRF_BIT(10)
+#define RK322X_GMAC_RMII_MODE_CLR	GRF_CLR_BIT(10)
+#define RK322X_GMAC_TXCLK_DLY_ENABLE	GRF_BIT(0)
+#define RK322X_GMAC_TXCLK_DLY_DISABLE	GRF_CLR_BIT(0)
+#define RK322X_GMAC_RXCLK_DLY_ENABLE	GRF_BIT(1)
+#define RK322X_GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(1)
+
+static void rk322x_set_to_rgmii(struct rk_priv_data *bsp_priv,
+				int tx_delay, int rx_delay)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK322X_GRF_MAC_CON1,
+		     RK322X_GMAC_PHY_INTF_SEL_RGMII |
+		     RK322X_GMAC_RMII_MODE_CLR |
+		     RK322X_GMAC_RXCLK_DLY_ENABLE |
+		     RK322X_GMAC_TXCLK_DLY_ENABLE);
+
+	regmap_write(bsp_priv->grf, RK322X_GRF_MAC_CON0,
+		     RK322X_GMAC_CLK_RX_DL_CFG(rx_delay) |
+		     RK322X_GMAC_CLK_TX_DL_CFG(tx_delay));
+}
+
+static void rk322x_set_to_rmii(struct rk_priv_data *bsp_priv)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK322X_GRF_MAC_CON1,
+		     RK322X_GMAC_PHY_INTF_SEL_RMII |
+		     RK322X_GMAC_RMII_MODE);
+
+	/* set MAC to RMII mode */
+	regmap_write(bsp_priv->grf, RK322X_GRF_MAC_CON1, GRF_BIT(11));
+}
+
+static void rk322x_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	if (speed == 10)
+		regmap_write(bsp_priv->grf, RK322X_GRF_MAC_CON1,
+			     RK322X_GMAC_CLK_2_5M);
+	else if (speed == 100)
+		regmap_write(bsp_priv->grf, RK322X_GRF_MAC_CON1,
+			     RK322X_GMAC_CLK_25M);
+	else if (speed == 1000)
+		regmap_write(bsp_priv->grf, RK322X_GRF_MAC_CON1,
+			     RK322X_GMAC_CLK_125M);
+	else
+		dev_err(dev, "unknown speed value for RGMII! speed=%d", speed);
+}
+
+static void rk322x_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	if (speed == 10)
+		regmap_write(bsp_priv->grf, RK322X_GRF_MAC_CON1,
+			     RK322X_GMAC_RMII_CLK_2_5M |
+			     RK322X_GMAC_SPEED_10M);
+	else if (speed == 100)
+		regmap_write(bsp_priv->grf, RK322X_GRF_MAC_CON1,
+			     RK322X_GMAC_RMII_CLK_25M |
+			     RK322X_GMAC_SPEED_100M);
+	else
+		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
+}
+
+static const struct rk_gmac_ops rk322x_ops = {
+	.set_to_rgmii = rk322x_set_to_rgmii,
+	.set_to_rmii = rk322x_set_to_rmii,
+	.set_rgmii_speed = rk322x_set_rgmii_speed,
+	.set_rmii_speed = rk322x_set_rmii_speed,
+};
+
 #define RK3288_GRF_SOC_CON1	0x0248
 #define RK3288_GRF_SOC_CON3	0x0250
 
@@ -604,6 +720,7 @@ static int rk_gmac_probe(struct platform_device *pdev)
 }
 
 static const struct of_device_id rk_gmac_dwmac_match[] = {
+	{ .compatible = "rockchip,rk322x-gmac", .data = &rk322x_ops },
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_ops },
 	{ .compatible = "rockchip,rk3368-gmac", .data = &rk3368_ops },
 	{ }
-- 
1.7.9.5
