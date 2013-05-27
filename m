From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 2/5] fec: Invert the order of error path sequence
Date: Mon, 27 May 2013 10:48:30 -0300
Message-ID: <1369662513-32133-3-git-send-email-fabio.estevam@freescale.com>
References: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <kernel@pengutronix.de>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:14025
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932403Ab3E0Ns6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 09:48:58 -0400
In-Reply-To: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently when fec_enet_init fails it jumps to 'failed_init' error path, which
will attemp to free the interrupts.

This is wrong because at this point the interrupts have not even been acquired.

Swap failed_init/failed_irq to fix the error path.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 57ac7c3..dc7388e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1975,13 +1975,13 @@ fec_probe(struct platform_device *pdev)
 failed_register:
 	fec_enet_mii_remove(fep);
 failed_mii_init:
-failed_init:
+failed_irq:
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
 		irq = platform_get_irq(pdev, i);
 		if (irq > 0)
 			free_irq(irq, ndev);
 	}
-failed_irq:
+failed_init:
 failed_regulator:
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
-- 
1.8.1.2
