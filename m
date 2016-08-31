From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [RESEND PATCH 1/4] net: stmmac: dwmac-rk: fixes the gmac resume after
 PD on/off
Date: Wed, 31 Aug 2016 14:13:45 +0800
Message-ID: <1472624028-7082-2-git-send-email-wxt@rock-chips.com>
References: <1472624028-7082-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
 Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>, dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
 Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472624028-7082-1-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
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

GMAC Power Domain(PD) will be disabled during suspend.
That will causes GRF registers reset.
So corresponding GRF registers for GMAC must be setup again.

Signed-off-by: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---

 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 9210591..289e7a6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -629,6 +629,16 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
 							"rockchip,grf");
 	bsp_priv->pdev = pdev;
 
+	gmac_clk_init(bsp_priv);
+
+	return bsp_priv;
+}
+
+static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
+{
+	int ret;
+	struct device *dev = &bsp_priv->pdev->dev;
+
 	/*rmii or rgmii*/
 	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RGMII) {
 		dev_info(dev, "init for RGMII\n");
@@ -641,15 +651,6 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
 		dev_err(dev, "NO interface defined!\n");
 	}
 
-	gmac_clk_init(bsp_priv);
-
-	return bsp_priv;
-}
-
-static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
-{
-	int ret;
-
 	ret = phy_power_on(bsp_priv, true);
 	if (ret)
 		return ret;
-- 
1.9.1
