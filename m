From: Caesar Wang <wxt@rock-chips.com>
Subject: [PATCH v3 8/9] clk: rockchip: associate SCLK_MAC_PLL and disable reparenting on rk3036
Date: Mon, 14 Mar 2016 16:01:59 +0800
Message-ID: <1457942520-12859-9-git-send-email-wxt@rock-chips.com>
References: <1457942520-12859-1-git-send-email-wxt@rock-chips.com>
Cc: linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org,
	Michael Turquette <mturquette@baylibre.com>,
	Stephen Boyd <sboyd@codeaurora.org>, linux-clk@vger.kernel.org,
	Caesar Wang <wxt@rock-chips.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36380 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933883AbcCNID6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 04:03:58 -0400
In-Reply-To: <1457942520-12859-1-git-send-email-wxt@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Stuebner <heiko@sntech.de>

The emac needs constant and very specific rate but the possible PLL-sources
are very limited, so we expect the PLL source to be set manually on per
board and don't want it to get changed in an automatic way later.
So add the necessary clock-id and disable reparenting on set_rate calls.

Signed-off-by: Heiko Stuebner <heiko@sntech.de>
Cc: Michael Turquette <mturquette@baylibre.com>
Cc: Heiko Stuebner <heiko@sntech.de>
Cc: Stephen Boyd <sboyd@codeaurora.org>
Cc: linux-clk@vger.kernel.org

Signed-off-by: Caesar Wang <wxt@rock-chips.com>
---

Changes in v3:
- Add the Cc people.

Changes in v2: None

 drivers/clk/rockchip/clk-rk3036.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/clk/rockchip/clk-rk3036.c b/drivers/clk/rockchip/clk-rk3036.c
index cc66e5f..7cdb2d6 100644
--- a/drivers/clk/rockchip/clk-rk3036.c
+++ b/drivers/clk/rockchip/clk-rk3036.c
@@ -348,7 +348,7 @@ static struct rockchip_clk_branch rk3036_clk_branches[] __initdata = {
 			RK2928_CLKSEL_CON(16), 0, 2, MFLAGS, 2, 5, DFLAGS,
 			RK2928_CLKGATE_CON(10), 5, GFLAGS),
 
-	COMPOSITE_NOGATE(0, "mac_pll_src", mux_pll_src_3plls_p, 0,
+	COMPOSITE_NOGATE(SCLK_MACPLL, "mac_pll_src", mux_pll_src_3plls_p, CLK_SET_RATE_NO_REPARENT,
 			RK2928_CLKSEL_CON(21), 0, 2, MFLAGS, 9, 5, DFLAGS),
 	MUX(SCLK_MACREF, "mac_clk_ref", mux_mac_p, CLK_SET_RATE_PARENT,
 			RK2928_CLKSEL_CON(21), 3, 1, MFLAGS),
-- 
1.9.1
