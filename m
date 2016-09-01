From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v4 1/6] net: stmmac: dwmac-rk: add rk3366 & rk3399 specific
 data
Date: Fri,  2 Sep 2016 01:49:59 +0800
Message-ID: <1472752204-8924-2-git-send-email-wxt@rock-chips.com>
References: <1472752204-8924-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
 Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
 Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472752204-8924-1-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
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

From: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>

Add constants and callback functions for the dwmac on rk3228/rk3229 socs.
As can be seen, the base structure is the same, only registers and the
bits in them moved slightly.

Signed-off-by: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Reviewed-by: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>

---

Changes in v4:
- Fixes from the original patch on https://patchwork.kernel.org/patch/9274557/

Changes in v3: None
Changes in v2: None

 .../devicetree/bindings/net/rockchip-dwmac.txt     |   8 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 226 +++++++++++++++++++++
 2 files changed, 232 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
index cccd945..95383c5 100644
--- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
@@ -3,8 +3,12 @@ Rockchip SoC RK3288 10/100/1000 Ethernet driver(GMAC)
 The device node has following properties.
 
 Required properties:
- - compatible: Can be one of "rockchip,rk3228-gmac", "rockchip,rk3288-gmac",
-                             "rockchip,rk3368-gmac"
+ - compatible: should be "rockchip,<name>-gamc"
+   "rockchip,rk3228-gmac": found on RK322x SoCs
+   "rockchip,rk3288-gmac": found on RK3288 SoCs
+   "rockchip,rk3366-gmac": found on RK3366 SoCs
+   "rockchip,rk3368-gmac": found on RK3368 SoCs
+   "rockchip,rk3399-gmac": found on RK3399 SoCs
  - reg: addresses and length of the register sets for the device.
  - interrupts: Should contain the GMAC interrupts.
  - interrupt-names: Should contain the interrupt names "macirq".
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 9210591..4e6a270 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -301,6 +301,118 @@ static const struct rk_gmac_ops rk3288_ops = {
 	.set_rmii_speed = rk3288_set_rmii_speed,
 };
 
+#define RK3366_GRF_SOC_CON6	0x0418
+#define RK3366_GRF_SOC_CON7	0x041c
+
+/* RK3366_GRF_SOC_CON6 */
+#define RK3366_GMAC_PHY_INTF_SEL_RGMII	(GRF_BIT(9) | GRF_CLR_BIT(10) | \
+					 GRF_CLR_BIT(11))
+#define RK3366_GMAC_PHY_INTF_SEL_RMII	(GRF_CLR_BIT(9) | GRF_CLR_BIT(10) | \
+					 GRF_BIT(11))
+#define RK3366_GMAC_FLOW_CTRL		GRF_BIT(8)
+#define RK3366_GMAC_FLOW_CTRL_CLR	GRF_CLR_BIT(8)
+#define RK3366_GMAC_SPEED_10M		GRF_CLR_BIT(7)
+#define RK3366_GMAC_SPEED_100M		GRF_BIT(7)
+#define RK3366_GMAC_RMII_CLK_25M	GRF_BIT(3)
+#define RK3366_GMAC_RMII_CLK_2_5M	GRF_CLR_BIT(3)
+#define RK3366_GMAC_CLK_125M		(GRF_CLR_BIT(4) | GRF_CLR_BIT(5))
+#define RK3366_GMAC_CLK_25M		(GRF_BIT(4) | GRF_BIT(5))
+#define RK3366_GMAC_CLK_2_5M		(GRF_CLR_BIT(4) | GRF_BIT(5))
+#define RK3366_GMAC_RMII_MODE		GRF_BIT(6)
+#define RK3366_GMAC_RMII_MODE_CLR	GRF_CLR_BIT(6)
+
+/* RK3366_GRF_SOC_CON7 */
+#define RK3366_GMAC_TXCLK_DLY_ENABLE	GRF_BIT(7)
+#define RK3366_GMAC_TXCLK_DLY_DISABLE	GRF_CLR_BIT(7)
+#define RK3366_GMAC_RXCLK_DLY_ENABLE	GRF_BIT(15)
+#define RK3366_GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(15)
+#define RK3366_GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 8)
+#define RK3366_GMAC_CLK_TX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 0)
+
+static void rk3366_set_to_rgmii(struct rk_priv_data *bsp_priv,
+				int tx_delay, int rx_delay)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+		     RK3366_GMAC_PHY_INTF_SEL_RGMII |
+		     RK3366_GMAC_RMII_MODE_CLR);
+	regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON7,
+		     RK3366_GMAC_RXCLK_DLY_ENABLE |
+		     RK3366_GMAC_TXCLK_DLY_ENABLE |
+		     RK3366_GMAC_CLK_RX_DL_CFG(rx_delay) |
+		     RK3366_GMAC_CLK_TX_DL_CFG(tx_delay));
+}
+
+static void rk3366_set_to_rmii(struct rk_priv_data *bsp_priv)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+		     RK3366_GMAC_PHY_INTF_SEL_RMII | RK3366_GMAC_RMII_MODE);
+}
+
+static void rk3366_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10)
+		regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+			     RK3366_GMAC_CLK_2_5M);
+	else if (speed == 100)
+		regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+			     RK3366_GMAC_CLK_25M);
+	else if (speed == 1000)
+		regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+			     RK3366_GMAC_CLK_125M);
+	else
+		dev_err(dev, "unknown speed value for RGMII! speed=%d", speed);
+}
+
+static void rk3366_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10) {
+		regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+			     RK3366_GMAC_RMII_CLK_2_5M |
+			     RK3366_GMAC_SPEED_10M);
+	} else if (speed == 100) {
+		regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+			     RK3366_GMAC_RMII_CLK_25M |
+			     RK3366_GMAC_SPEED_100M);
+	} else {
+		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
+	}
+}
+
+static const struct rk_gmac_ops rk3366_ops = {
+	.set_to_rgmii = rk3366_set_to_rgmii,
+	.set_to_rmii = rk3366_set_to_rmii,
+	.set_rgmii_speed = rk3366_set_rgmii_speed,
+	.set_rmii_speed = rk3366_set_rmii_speed,
+};
+
 #define RK3368_GRF_SOC_CON15	0x043c
 #define RK3368_GRF_SOC_CON16	0x0440
 
@@ -413,6 +525,118 @@ static const struct rk_gmac_ops rk3368_ops = {
 	.set_rmii_speed = rk3368_set_rmii_speed,
 };
 
+#define RK3399_GRF_SOC_CON5	0xc214
+#define RK3399_GRF_SOC_CON6	0xc218
+
+/* RK3399_GRF_SOC_CON5 */
+#define RK3399_GMAC_PHY_INTF_SEL_RGMII	(GRF_BIT(9) | GRF_CLR_BIT(10) | \
+					 GRF_CLR_BIT(11))
+#define RK3399_GMAC_PHY_INTF_SEL_RMII	(GRF_CLR_BIT(9) | GRF_CLR_BIT(10) | \
+					 GRF_BIT(11))
+#define RK3399_GMAC_FLOW_CTRL		GRF_BIT(8)
+#define RK3399_GMAC_FLOW_CTRL_CLR	GRF_CLR_BIT(8)
+#define RK3399_GMAC_SPEED_10M		GRF_CLR_BIT(7)
+#define RK3399_GMAC_SPEED_100M		GRF_BIT(7)
+#define RK3399_GMAC_RMII_CLK_25M	GRF_BIT(3)
+#define RK3399_GMAC_RMII_CLK_2_5M	GRF_CLR_BIT(3)
+#define RK3399_GMAC_CLK_125M		(GRF_CLR_BIT(4) | GRF_CLR_BIT(5))
+#define RK3399_GMAC_CLK_25M		(GRF_BIT(4) | GRF_BIT(5))
+#define RK3399_GMAC_CLK_2_5M		(GRF_CLR_BIT(4) | GRF_BIT(5))
+#define RK3399_GMAC_RMII_MODE		GRF_BIT(6)
+#define RK3399_GMAC_RMII_MODE_CLR	GRF_CLR_BIT(6)
+
+/* RK3399_GRF_SOC_CON6 */
+#define RK3399_GMAC_TXCLK_DLY_ENABLE	GRF_BIT(7)
+#define RK3399_GMAC_TXCLK_DLY_DISABLE	GRF_CLR_BIT(7)
+#define RK3399_GMAC_RXCLK_DLY_ENABLE	GRF_BIT(15)
+#define RK3399_GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(15)
+#define RK3399_GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 8)
+#define RK3399_GMAC_CLK_TX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 0)
+
+static void rk3399_set_to_rgmii(struct rk_priv_data *bsp_priv,
+				int tx_delay, int rx_delay)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+		     RK3399_GMAC_PHY_INTF_SEL_RGMII |
+		     RK3399_GMAC_RMII_MODE_CLR);
+	regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON6,
+		     RK3399_GMAC_RXCLK_DLY_ENABLE |
+		     RK3399_GMAC_TXCLK_DLY_ENABLE |
+		     RK3399_GMAC_CLK_RX_DL_CFG(rx_delay) |
+		     RK3399_GMAC_CLK_TX_DL_CFG(tx_delay));
+}
+
+static void rk3399_set_to_rmii(struct rk_priv_data *bsp_priv)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+		     RK3399_GMAC_PHY_INTF_SEL_RMII | RK3399_GMAC_RMII_MODE);
+}
+
+static void rk3399_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10)
+		regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+			     RK3399_GMAC_CLK_2_5M);
+	else if (speed == 100)
+		regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+			     RK3399_GMAC_CLK_25M);
+	else if (speed == 1000)
+		regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+			     RK3399_GMAC_CLK_125M);
+	else
+		dev_err(dev, "unknown speed value for RGMII! speed=%d", speed);
+}
+
+static void rk3399_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10) {
+		regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+			     RK3399_GMAC_RMII_CLK_2_5M |
+			     RK3399_GMAC_SPEED_10M);
+	} else if (speed == 100) {
+		regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+			     RK3399_GMAC_RMII_CLK_25M |
+			     RK3399_GMAC_SPEED_100M);
+	} else {
+		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
+	}
+}
+
+static const struct rk_gmac_ops rk3399_ops = {
+	.set_to_rgmii = rk3399_set_to_rgmii,
+	.set_to_rmii = rk3399_set_to_rmii,
+	.set_rgmii_speed = rk3399_set_rgmii_speed,
+	.set_rmii_speed = rk3399_set_rmii_speed,
+};
+
 static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
@@ -760,7 +984,9 @@ static int rk_gmac_probe(struct platform_device *pdev)
 static const struct of_device_id rk_gmac_dwmac_match[] = {
 	{ .compatible = "rockchip,rk3228-gmac", .data = &rk3228_ops },
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_ops },
+	{ .compatible = "rockchip,rk3366-gmac", .data = &rk3366_ops },
 	{ .compatible = "rockchip,rk3368-gmac", .data = &rk3368_ops },
+	{ .compatible = "rockchip,rk3399-gmac", .data = &rk3399_ops },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, rk_gmac_dwmac_match);
-- 
1.9.1
