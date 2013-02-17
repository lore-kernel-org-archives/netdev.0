From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH v2 2/2] net: fec: Improve logging
Date: Sun, 17 Feb 2013 10:36:44 -0300
Message-ID: <1361108204-9498-2-git-send-email-festevam@gmail.com>
References: <1361108204-9498-1-git-send-email-festevam@gmail.com>
Cc: s.hauer@pengutronix.de, shawn.guo@linaro.org, marex@denx.de,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f180.google.com ([209.85.213.180]:59958 "EHLO
	mail-ye0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756189Ab3BQNg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 08:36:59 -0500
Received: by mail-ye0-f180.google.com with SMTP id r14so859528yen.11
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2013 05:36:59 -0800 (PST)
In-Reply-To: <1361108204-9498-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Replace pr_debug with dev_dbg to improve the logging style.
dev_dbg indicates the device name in the log, which is useful for debugging 
purposes when we have a dual FEC system, such as mx28. 

Also use "phy-reset-gpios" in the message to correlate with the device tree
property.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1:
- Use dev_dbg instead of dev_err
 drivers/net/ethernet/freescale/fec.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 5864a67..29d82cf 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1695,7 +1695,7 @@ static void fec_reset_phy(struct platform_device *pdev)
 	err = devm_gpio_request_one(&pdev->dev, phy_reset,
 				    GPIOF_OUT_INIT_LOW, "phy-reset");
 	if (err) {
-		pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
+		dev_dbg(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
 		return;
 	}
 	msleep(msec);
-- 
1.7.9.5
