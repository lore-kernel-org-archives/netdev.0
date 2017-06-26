From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] ti: wl18xx: add checks on wl18xx_top_reg_write() return value
Date: Mon, 26 Jun 2017 18:06:19 -0500
Message-ID: <20170626230619.GA14831@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check return value from call to wl18xx_top_reg_write(),
so in case of error jump to goto label out and return.

Also, remove unnecessary value check before goto label out.

Addresses-Coverity-ID: 1226938
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/wireless/ti/wl18xx/main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ti/wl18xx/main.c b/drivers/net/wireless/ti/wl18xx/main.c
index d1aa3ee..0cf3b40 100644
--- a/drivers/net/wireless/ti/wl18xx/main.c
+++ b/drivers/net/wireless/ti/wl18xx/main.c
@@ -793,9 +793,13 @@ static int wl18xx_set_clk(struct wl1271 *wl)
 		ret = wl18xx_top_reg_write(wl, PLLSH_WCS_PLL_P_FACTOR_CFG_2,
 					(wl18xx_clk_table[clk_freq].p >> 16) &
 					PLLSH_WCS_PLL_P_FACTOR_CFG_2_MASK);
+		if (ret < 0)
+			goto out;
 	} else {
 		ret = wl18xx_top_reg_write(wl, PLLSH_WCS_PLL_SWALLOW_EN,
 					   PLLSH_WCS_PLL_SWALLOW_EN_VAL2);
+		if (ret < 0)
+			goto out;
 	}
 
 	/* choose WCS PLL */
@@ -819,8 +823,6 @@ static int wl18xx_set_clk(struct wl1271 *wl)
 	/* reset the swallowing logic */
 	ret = wl18xx_top_reg_write(wl, PLLSH_COEX_PLL_SWALLOW_EN,
 				   PLLSH_COEX_PLL_SWALLOW_EN_VAL2);
-	if (ret < 0)
-		goto out;
 
 out:
 	return ret;
-- 
2.5.0
