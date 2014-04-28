From: George Cherian <george.cherian@ti.com>
Subject: [PATCH 5/6] ARM: AM43xx: clk: Change the cpts ref clock source to dpll_core_m5 clk
Date: Mon, 28 Apr 2014 09:40:24 +0530
Message-ID: <1398658225-25873-6-git-send-email-george.cherian@ti.com>
References: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <richardcochran@gmail.com>,
	<jeffrey.t.kirsher@intel.com>, <dborkman@redhat.com>,
	<ast@plumgrid.com>, <tklauser@distanz.ch>, <mpa@pengutronix.de>,
	<bhutchings@solarflare.com>, <zonque@gmail.com>, <balbi@ti.com>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <t-kristo@ti.com>,
	<mturquette@linaro.org>, <linux@arm.linux.org.uk>,
	<galak@codeaurora.org>, <ijc+devicetree@hellion.org.uk>,
	<mark.rutland@arm.com>, <pawel.moll@arm.com>, <robh+dt@kernel.org>,
	<tony@atomide.com>, <bcousson@baylibre.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cpsw_cpts_rft_clk has got the choice of 3 clocksources
 -dpll_core_m4_ck
 -dpll_core_m5_ck
 -dpll_disp_m2_ck

By default dpll_core_m4_ck is selected, witn this as clock
source the CPTS doesnot work properly. It gives clockcheck errors
while running PTP.

 clockcheck: clock jumped backward or running slower than expected!

By selecting dpll_core_m5_ck as the clocksource fixes this issue.
In AM335x dpll_core_m5_ck is the default clocksource.

Signed-off-by: George Cherian <george.cherian@ti.com>
---
 drivers/clk/ti/clk-43xx.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/clk/ti/clk-43xx.c b/drivers/clk/ti/clk-43xx.c
index 67c8de5..b4877e0 100644
--- a/drivers/clk/ti/clk-43xx.c
+++ b/drivers/clk/ti/clk-43xx.c
@@ -110,9 +110,25 @@ static struct ti_dt_clk am43xx_clks[] = {
 
 int __init am43xx_dt_clk_init(void)
 {
+	struct clk *clk1, *clk2;
+
 	ti_dt_clocks_register(am43xx_clks);
 
 	omap2_clk_disable_autoidle_all();
 
+	/*
+	 * cpsw_cpts_rft_clk  has got the choice of 3 clocksources
+	 * dpll_core_m4_ck, dpll_core_m5_ck and dpll_disp_m2_ck.
+	 * By default dpll_core_m4_ck is selected, witn this as clock
+	 * source the CPTS doesnot work properly. It gives clockcheck errors
+	 * while running PTP.
+	 * clockcheck: clock jumped backward or running slower than expected!
+	 * By selecting dpll_core_m5_ck as the clocksource fixes this issue.
+	 * In AM335x dpll_core_m5_ck is the default clocksource.
+	 */
+	clk1 = clk_get_sys(NULL, "cpsw_cpts_rft_clk");
+	clk2 = clk_get_sys(NULL, "dpll_core_m5_ck");
+	clk_set_parent(clk1, clk2);
+
 	return 0;
 }
-- 
1.8.3.1
