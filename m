From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH RESEND 2/5] net: fec: adopt pinctrl support
Date: Mon,  7 May 2012 08:53:57 +0800
Message-ID: <1336352040-28447-3-git-send-email-shawn.guo@linaro.org>
References: <1336352040-28447-1-git-send-email-shawn.guo@linaro.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Dong Aisheng <dong.aisheng@linaro.org>,
	Shawn Guo <shawn.guo@linaro.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61005 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755077Ab2EGAx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2012 20:53:57 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so6011295pbb.19
        for <netdev@vger.kernel.org>; Sun, 06 May 2012 17:53:57 -0700 (PDT)
In-Reply-To: <1336352040-28447-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: netdev@vger.kernel.org
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index a12b3f5..500c106 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -48,6 +48,7 @@
 #include <linux/of_device.h>
 #include <linux/of_gpio.h>
 #include <linux/of_net.h>
+#include <linux/pinctrl/consumer.h>
 
 #include <asm/cacheflush.h>
 
@@ -1542,6 +1543,7 @@ fec_probe(struct platform_device *pdev)
 	struct resource *r;
 	const struct of_device_id *of_id;
 	static int dev_id;
+	struct pinctrl *pinctrl;
 
 	of_id = of_match_device(fec_dt_ids, &pdev->dev);
 	if (of_id)
@@ -1609,6 +1611,12 @@ fec_probe(struct platform_device *pdev)
 		}
 	}
 
+	pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
+	if (IS_ERR(pinctrl)) {
+		ret = PTR_ERR(pinctrl);
+		goto failed_pin;
+	}
+
 	fep->clk = clk_get(&pdev->dev, NULL);
 	if (IS_ERR(fep->clk)) {
 		ret = PTR_ERR(fep->clk);
@@ -1639,6 +1647,7 @@ failed_mii_init:
 failed_init:
 	clk_disable_unprepare(fep->clk);
 	clk_put(fep->clk);
+failed_pin:
 failed_clk:
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
 		irq = platform_get_irq(pdev, i);
-- 
1.7.5.4
