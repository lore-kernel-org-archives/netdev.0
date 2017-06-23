From: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH 06/11] net: stmmac: dwmac-rk: Add internal phy support for rk3228
Date: Fri, 23 Jun 2017 12:59:47 +0800
Message-ID: <1498193987-8070-1-git-send-email-david.wu@rock-chips.com>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
Cc: andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
        olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1498192929-7519-1-git-send-email-david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is only one mac controller in rk3228, which could connect to
external phy or internal phy, use the grf_com_mux bit15 to route
external/internal phy.

Change-Id: I3a366677047b8032eb535abb0c3e56fa7722aa2e
Signed-off-by: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index c1a1413..90e1fc8 100644
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
+#define RK3228_GRF_CON_MUX_GMAC_INTERNAL_PHY	GRF_BIT(15)
+
 static void rk3228_set_to_rgmii(struct rk_priv_data *bsp_priv,
 				int tx_delay, int rx_delay)
 {
@@ -191,11 +196,18 @@ static void rk3228_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
 }
 
+static void rk3228_internal_phy_powerup(struct rk_priv_data *priv)
+{
+	regmap_write(priv->grf, RK3228_GRF_CON_MUX,
+		     RK3228_GRF_CON_MUX_GMAC_INTERNAL_PHY);
+}
+
 static const struct rk_gmac_ops rk3228_ops = {
 	.set_to_rgmii = rk3228_set_to_rgmii,
 	.set_to_rmii = rk3228_set_to_rmii,
 	.set_rgmii_speed = rk3228_set_rgmii_speed,
 	.set_rmii_speed = rk3228_set_rmii_speed,
+	.internal_phy_powerup =  rk3228_internal_phy_powerup,
 };
 
 #define RK3288_GRF_SOC_CON1	0x0248
-- 
1.9.1


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
