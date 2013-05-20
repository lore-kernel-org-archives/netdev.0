From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 1/2] fec: Let device core handle pinctrl
Date: Mon, 20 May 2013 10:06:17 -0300
Message-ID: <1369055178-6083-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.88.13] ([65.55.88.13]:36359 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756812Ab3ETNHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 09:07:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit ab78029 (drivers/pinctrl: grab default handles from device core)
we can rely on device core for handling pinctrl, so remove 
devm_pinctrl_get_select_default() from the driver.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 570dfad..e277860 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -53,7 +53,6 @@
 #include <linux/of_device.h>
 #include <linux/of_gpio.h>
 #include <linux/of_net.h>
-#include <linux/pinctrl/consumer.h>
 #include <linux/regulator/consumer.h>
 
 #include <asm/cacheflush.h>
@@ -1841,7 +1840,6 @@ fec_probe(struct platform_device *pdev)
 	struct resource *r;
 	const struct of_device_id *of_id;
 	static int dev_id;
-	struct pinctrl *pinctrl;
 	struct regulator *reg_phy;
 
 	of_id = of_match_device(fec_dt_ids, &pdev->dev);
@@ -1891,12 +1889,6 @@ fec_probe(struct platform_device *pdev)
 		fep->phy_interface = ret;
 	}
 
-	pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
-	if (IS_ERR(pinctrl)) {
-		ret = PTR_ERR(pinctrl);
-		goto failed_pin;
-	}
-
 	fep->clk_ipg = devm_clk_get(&pdev->dev, "ipg");
 	if (IS_ERR(fep->clk_ipg)) {
 		ret = PTR_ERR(fep->clk_ipg);
@@ -1996,7 +1988,6 @@ failed_regulator:
 	clk_disable_unprepare(fep->clk_ipg);
 	clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ptp);
-failed_pin:
 failed_clk:
 failed_ioremap:
 	free_netdev(ndev);
-- 
1.8.1.2
