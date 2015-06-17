From: Heiko Stuebner <heiko@sntech.de>
Subject: [PATCH 2/4] net: stmmac: dwmac-rk: Fix clk rate when provided by soc
Date: Wed, 17 Jun 2015 23:54:44 +0200
Message-ID: <1434578086-12209-3-git-send-email-heiko@sntech.de>
References: <1434578086-12209-1-git-send-email-heiko@sntech.de>
Cc: roger.chen@rock-chips.com, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heiko Stuebner <heiko@sntech.de>, stable@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434578086-12209-1-git-send-email-heiko@sntech.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first iteration of the dwmac-rk support did access an intermediate
clock directly below the pll selector. This was removed in a subsequent
revision, but the clock and one invocation remained. This results in
the driver trying to set the rate of a non-existent clock when the soc
and not some external source provides the phy clock for RMII phys.

So set the rate of the correct clock and remove the remaining now
completely unused definition.

Fixes: 436f5ae08f9d ("GMAC: add driver for Rockchip RK3288 SoCs integrated GMAC")
Cc: stable@vger.kernel.org
Signed-off-by: Heiko Stuebner <heiko@sntech.de>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 49c7715..4faa283 100644
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
 		dev_info(dev, "%s: clock input from PHY\n", __func__);
 	} else {
 		if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII)
-			clk_set_rate(bsp_priv->clk_mac_pll, 50000000);
+			clk_set_rate(bsp_priv->clk_mac, 50000000);
 	}
 
 	return 0;
-- 
2.1.4
