From: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH v2 2/4] net: stmmac: dwmac-rk: Fix clk rate when provided by
 soc
Date: Sun, 21 Jun 2015 21:52:52 +0200
Message-ID: <1434916374-7457-3-git-send-email-heiko@sntech.de>
References: <1434916374-7457-1-git-send-email-heiko@sntech.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org
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

The first iteration of the dwmac-rk support did access an intermediate
clock directly below the pll selector. This was removed in a subsequent
revision, but the clock and one invocation remained. This results in
the driver trying to set the rate of a non-existent clock when the soc
and not some external source provides the phy clock for RMII phys.

So set the rate of the correct clock and remove the remaining now
completely unused definition.

Fixes: 436f5ae08f9d ("GMAC: add driver for Rockchip RK3288 SoCs integrated GMAC")
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index a396070..5dafebb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -42,7 +42,6 @@ struct rk_priv_data {
 	bool clock_input;
 
 	struct clk *clk_mac;
-	struct clk *clk_mac_pll;
 	struct clk *gmac_clkin;
 	struct clk *mac_clk_rx;
 	struct clk *mac_clk_tx;
@@ -209,7 +208,7 @@ static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 		dev_info(dev, "clock input from PHY\n");
 	} else {
 		if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII)
-			clk_set_rate(bsp_priv->clk_mac_pll, 50000000);
+			clk_set_rate(bsp_priv->clk_mac, 50000000);
 	}
 
 	return 0;
-- 
2.1.4
