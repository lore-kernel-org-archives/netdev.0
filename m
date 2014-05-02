From: George Cherian <george.cherian@ti.com>
Subject: [PATCH v2 5/6] ARM: AM43xx: clk: Change the cpts ref clock source to
 dpll_core_m5 clk
Date: Fri, 2 May 2014 12:02:03 +0530
Message-ID: <1399012324-20737-6-git-send-email-george.cherian@ti.com>
References: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, tony@atomide.com, ast@plumgrid.com,
 mturquette@linaro.org, jeffrey.t.kirsher@intel.com, tklauser@distanz.ch,
 mugunthanvnm@ti.com, george.cherian@ti.com, pawel.moll@arm.com,
 ijc+devicetree@hellion.org.uk, richardcochran@gmail.com, robh+dt@kernel.org,
 bhutchings@solarflare.com, linux@arm.linux.org.uk, balbi@ti.com,
 zonque@gmail.com, t-kristo@ti.com, dborkman@redhat.com, bcousson@baylibre.com,
 galak@codeaurora.org, mpa@pengutronix.de, davem@davemloft.net
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>, <devicetree@vger.kernel.org>,
 <linux-omap@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
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
