From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/4] can: flexcan: use correct clock as base for bit rate calculation
Date: Wed, 27 Nov 2013 22:11:35 +0100
Message-ID: <1385586695-11134-5-git-send-email-mkl@pengutronix.de>
References: <1385586695-11134-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49165 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757815Ab3K0VLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 16:11:54 -0500
In-Reply-To: <1385586695-11134-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flexcan IP core uses the peripheral clock ("per") as basic clock for the
bit timing calculation. However the driver uses the the wrong clock ("ipg").
This leads to wrong bit rates if the rates on both clock are different.

This patch fixes the problem by using the correct clock for the bit rate
calculation.

Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index ae08cf1..aaed97b 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -1020,13 +1020,13 @@ static int flexcan_probe(struct platform_device *pdev)
 			dev_err(&pdev->dev, "no ipg clock defined\n");
 			return PTR_ERR(clk_ipg);
 		}
-		clock_freq = clk_get_rate(clk_ipg);
 
 		clk_per = devm_clk_get(&pdev->dev, "per");
 		if (IS_ERR(clk_per)) {
 			dev_err(&pdev->dev, "no per clock defined\n");
 			return PTR_ERR(clk_per);
 		}
+		clock_freq = clk_get_rate(clk_per);
 	}
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-- 
1.8.5.rc0
