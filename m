From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH 2/2] net: fec: Improve logging
Date: Sat, 16 Feb 2013 20:53:27 -0200
Message-ID: <1361055207-22870-2-git-send-email-festevam@gmail.com>
References: <1361055207-22870-1-git-send-email-festevam@gmail.com>
Cc: s.hauer@pengutronix.de, shawn.guo@linaro.org, marex@denx.de,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:33145 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754905Ab3BPWxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 17:53:47 -0500
Received: by mail-gg0-f174.google.com with SMTP id k5so343967ggd.5
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2013 14:53:46 -0800 (PST)
In-Reply-To: <1361055207-22870-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

In case the request of the GPIO reset fails it is interesting to log
such error even if DEBUG is not enabled, so promote the message to dev_err. 

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
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
+		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
 		return;
 	}
 	msleep(msec);
-- 
1.7.9.5
