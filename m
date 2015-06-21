From: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH v2 4/4] net: stmmac: dwmac-rk: add rk3368-specific data
Date: Sun, 21 Jun 2015 21:52:54 +0200
Message-ID: <1434916374-7457-5-git-send-email-heiko@sntech.de>
References: <1434916374-7457-1-git-send-email-heiko@sntech.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1434916374-7457-1-git-send-email-heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
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

Add constants and callback functions for the dwmac on rk3368 socs.
As can be seen, the base structure is the same, only registers and
the bits in them moved slightly.

Signed-off-by: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
---
 .../devicetree/bindings/net/rockchip-dwmac.txt     |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 126 +++++++++++++++++++++
 2 files changed, 127 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
index 21fd199..93eac7c 100644
--- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
@@ -3,7 +3,7 @@ Rockchip SoC RK3288 10/100/1000 Ethernet driver(GMAC)
 The device node has following properties.
 
 Required properties:
- - compatible: Can be "rockchip,rk3288-gmac".
+ - compatible: Can be one of "rockchip,rk3288-gmac", "rockchip,rk3368-gmac"
  - reg: addresses and length of the register sets for the device.
  - interrupts: Should contain the GMAC interrupts.
  - interrupt-names: Should contain the interrupt names "macirq".
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 65afca6..00a1e1e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -184,6 +184,118 @@ struct rk_gmac_ops rk3288_ops = {
 	.set_rmii_speed = rk3288_set_rmii_speed,
 };
 
+#define RK3368_GRF_SOC_CON15	0x043c
+#define RK3368_GRF_SOC_CON16	0x0440
+
+/* RK3368_GRF_SOC_CON15 */
+#define RK3368_GMAC_PHY_INTF_SEL_RGMII	(GRF_BIT(9) | GRF_CLR_BIT(10) | \
+					 GRF_CLR_BIT(11))
+#define RK3368_GMAC_PHY_INTF_SEL_RMII	(GRF_CLR_BIT(9) | GRF_CLR_BIT(10) | \
+					 GRF_BIT(11))
+#define RK3368_GMAC_FLOW_CTRL		GRF_BIT(8)
+#define RK3368_GMAC_FLOW_CTRL_CLR	GRF_CLR_BIT(8)
+#define RK3368_GMAC_SPEED_10M		GRF_CLR_BIT(7)
+#define RK3368_GMAC_SPEED_100M		GRF_BIT(7)
+#define RK3368_GMAC_RMII_CLK_25M	GRF_BIT(3)
+#define RK3368_GMAC_RMII_CLK_2_5M	GRF_CLR_BIT(3)
+#define RK3368_GMAC_CLK_125M		(GRF_CLR_BIT(4) | GRF_CLR_BIT(5))
+#define RK3368_GMAC_CLK_25M		(GRF_BIT(4) | GRF_BIT(5))
+#define RK3368_GMAC_CLK_2_5M		(GRF_CLR_BIT(4) | GRF_BIT(5))
+#define RK3368_GMAC_RMII_MODE		GRF_BIT(6)
+#define RK3368_GMAC_RMII_MODE_CLR	GRF_CLR_BIT(6)
+
+/* RK3368_GRF_SOC_CON16 */
+#define RK3368_GMAC_TXCLK_DLY_ENABLE	GRF_BIT(7)
+#define RK3368_GMAC_TXCLK_DLY_DISABLE	GRF_CLR_BIT(7)
+#define RK3368_GMAC_RXCLK_DLY_ENABLE	GRF_BIT(15)
+#define RK3368_GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(15)
+#define RK3368_GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 8)
+#define RK3368_GMAC_CLK_TX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 0)
+
+static void rk3368_set_to_rgmii(struct rk_priv_data *bsp_priv,
+				int tx_delay, int rx_delay)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3368_GRF_SOC_CON15,
+		     RK3368_GMAC_PHY_INTF_SEL_RGMII |
+		     RK3368_GMAC_RMII_MODE_CLR);
+	regmap_write(bsp_priv->grf, RK3368_GRF_SOC_CON16,
+		     RK3368_GMAC_RXCLK_DLY_ENABLE |
+		     RK3368_GMAC_TXCLK_DLY_ENABLE |
+		     RK3368_GMAC_CLK_RX_DL_CFG(rx_delay) |
+		     RK3368_GMAC_CLK_TX_DL_CFG(tx_delay));
+}
+
+static void rk3368_set_to_rmii(struct rk_priv_data *bsp_priv)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3368_GRF_SOC_CON15,
+		     RK3368_GMAC_PHY_INTF_SEL_RMII | RK3368_GMAC_RMII_MODE);
+}
+
+static void rk3368_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10)
+		regmap_write(bsp_priv->grf, RK3368_GRF_SOC_CON15,
+			     RK3368_GMAC_CLK_2_5M);
+	else if (speed == 100)
+		regmap_write(bsp_priv->grf, RK3368_GRF_SOC_CON15,
+			     RK3368_GMAC_CLK_25M);
+	else if (speed == 1000)
+		regmap_write(bsp_priv->grf, RK3368_GRF_SOC_CON15,
+			     RK3368_GMAC_CLK_125M);
+	else
+		dev_err(dev, "unknown speed value for RGMII! speed=%d", speed);
+}
+
+static void rk3368_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10) {
+		regmap_write(bsp_priv->grf, RK3368_GRF_SOC_CON15,
+			     RK3368_GMAC_RMII_CLK_2_5M |
+			     RK3368_GMAC_SPEED_10M);
+	} else if (speed == 100) {
+		regmap_write(bsp_priv->grf, RK3368_GRF_SOC_CON15,
+			     RK3368_GMAC_RMII_CLK_25M |
+			     RK3368_GMAC_SPEED_100M);
+	} else {
+		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
+	}
+}
+
+struct rk_gmac_ops rk3368_ops = {
+	.set_to_rgmii = rk3368_set_to_rgmii,
+	.set_to_rmii = rk3368_set_to_rmii,
+	.set_rgmii_speed = rk3368_set_rgmii_speed,
+	.set_rmii_speed = rk3368_set_rmii_speed,
+};
+
 static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
@@ -422,6 +534,11 @@ static void *rk3288_gmac_setup(struct platform_device *pdev)
 	return rk_gmac_setup(pdev, &rk3288_ops);
 }
 
+static void *rk3368_gmac_setup(struct platform_device *pdev)
+{
+	return rk_gmac_setup(pdev, &rk3368_ops);
+}
+
 static int rk_gmac_init(struct platform_device *pdev, void *priv)
 {
 	struct rk_priv_data *bsp_priv = priv;
@@ -467,8 +584,17 @@ static const struct stmmac_of_data rk3288_gmac_data = {
 	.exit = rk_gmac_exit,
 };
 
+static const struct stmmac_of_data rk3368_gmac_data = {
+	.has_gmac = 1,
+	.fix_mac_speed = rk_fix_speed,
+	.setup = rk3368_gmac_setup,
+	.init = rk_gmac_init,
+	.exit = rk_gmac_exit,
+};
+
 static const struct of_device_id rk_gmac_dwmac_match[] = {
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_gmac_data},
+	{ .compatible = "rockchip,rk3368-gmac", .data = &rk3368_gmac_data},
 	{ }
 };
 MODULE_DEVICE_TABLE(of, rk_gmac_dwmac_match);
-- 
2.1.4
