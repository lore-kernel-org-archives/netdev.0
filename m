From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 3/4] stmmac: dwmac-rk: absorb rk_gmac_init into probe
Date: Sat,  5 Nov 2016 14:04:51 +0100
Message-ID: <20161105130452.24226-4-manabian@gmail.com>
References: <20161105130452.24226-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, heiko@sntech.de,
        linux-rockchip@lists.infradead.org, vpalatin@chromium.org,
        peppe.cavallaro@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35108 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753910AbcKENFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2016 09:05:16 -0400
Received: by mail-lf0-f66.google.com with SMTP id p100so6148258lfg.2
        for <netdev@vger.kernel.org>; Sat, 05 Nov 2016 06:05:16 -0700 (PDT)
In-Reply-To: <20161105130452.24226-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the rk_gmac_init() only calls another function move this
function call into probe so rk_gmac_init() can be removed.

Since commit cecbc5563a02 ("stmmac: allow to split suspend/resume
from init/exit callbacks") the init hook is no longer used in
dwmac-rk so this can be removed.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 8506881..6b787d7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -901,13 +901,6 @@ static void rk_gmac_powerdown(struct rk_priv_data *gmac)
 	gmac_clk_enable(gmac, false);
 }
 
-static int rk_gmac_init(struct platform_device *pdev, void *priv)
-{
-	struct rk_priv_data *bsp_priv = priv;
-
-	return rk_gmac_powerup(bsp_priv);
-}
-
 static void rk_fix_speed(void *priv, unsigned int speed)
 {
 	struct rk_priv_data *bsp_priv = priv;
@@ -943,14 +936,13 @@ static int rk_gmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	plat_dat->has_gmac = true;
-	plat_dat->init = rk_gmac_init;
 	plat_dat->fix_mac_speed = rk_fix_speed;
 
 	plat_dat->bsp_priv = rk_gmac_setup(pdev, data);
 	if (IS_ERR(plat_dat->bsp_priv))
 		return PTR_ERR(plat_dat->bsp_priv);
 
-	ret = rk_gmac_init(pdev, plat_dat->bsp_priv);
+	ret = rk_gmac_powerup(plat_dat->bsp_priv);
 	if (ret)
 		return ret;
 
-- 
2.10.2
