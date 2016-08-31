From: Caesar Wang <wxt@rock-chips.com>
Subject: [RESEND PATCH 2/4] net: stmmac: dwmac-rk: add pd_gmac support for rk3399
Date: Wed, 31 Aug 2016 14:13:46 +0800
Message-ID: <1472624028-7082-3-git-send-email-wxt@rock-chips.com>
References: <1472624028-7082-1-git-send-email-wxt@rock-chips.com>
Cc: linux-rockchip@lists.infradead.org,
        Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>,
        dbasehore@chromium.org, David Wu <david.wu@rock-chips.com>,
        Caesar Wang <wxt@rock-chips.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-kernel@vger.kernel.org
To: Heiko Stuebner <heiko@sntech.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33276 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752245AbcHaGO3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 02:14:29 -0400
In-Reply-To: <1472624028-7082-1-git-send-email-wxt@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Wu <david.wu@rock-chips.com>

Add the gmac power domain support for rk3399, in order to save more
power consumption.

Signed-off-by: David Wu <david.wu@rock-chips.com>
Signed-off-by: Caesar Wang <wxt@rock-chips.com>
---

 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 289e7a6..406573d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -30,6 +30,7 @@
 #include <linux/delay.h>
 #include <linux/mfd/syscon.h>
 #include <linux/regmap.h>
+#include <linux/pm_runtime.h>
 
 #include "stmmac_platform.h"
 
@@ -659,11 +660,19 @@ static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
 	if (ret)
 		return ret;
 
+	pm_runtime_enable(dev);
+	pm_runtime_get_sync(dev);
+
 	return 0;
 }
 
 static void rk_gmac_powerdown(struct rk_priv_data *gmac)
 {
+	struct device *dev = &gmac->pdev->dev;
+
+	pm_runtime_put_sync(dev);
+	pm_runtime_disable(dev);
+
 	phy_power_on(gmac, false);
 	gmac_clk_enable(gmac, false);
 }
-- 
1.9.1
