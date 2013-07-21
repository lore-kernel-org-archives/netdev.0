From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH 3/6] fec: Enable/disable clk_ptp in suspend/resume
Date: Sun, 21 Jul 2013 13:25:01 -0300
Message-ID: <1374423904-2668-4-git-send-email-festevam@gmail.com>
References: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Cc: kernel@pengutronix.de, Frank.Li@freescale.com,
	shawn.guo@linaro.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f181.google.com ([209.85.213.181]:45869 "EHLO
	mail-ye0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab3GUQZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 12:25:38 -0400
Received: by mail-ye0-f181.google.com with SMTP id g12so1845568yee.26
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 09:25:38 -0700 (PDT)
In-Reply-To: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

clk_ptp should also be enabled in fec_resume() and disabled in fec_suspend().

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 5e82200..886a372 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2234,6 +2234,8 @@ fec_suspend(struct device *dev)
 		fec_stop(ndev);
 		netif_device_detach(ndev);
 	}
+	if (fep->clk_ptp)
+		clk_disable_unprepare(fep->clk_ptp);
 	if (fep->clk_enet_out)
 		clk_disable_unprepare(fep->clk_enet_out);
 	clk_disable_unprepare(fep->clk_ipg);
@@ -2262,6 +2264,8 @@ fec_resume(struct device *dev)
 	clk_prepare_enable(fep->clk_ipg);
 	if (fep->clk_enet_out)
 		clk_prepare_enable(fep->clk_enet_out);
+	if (fep->clk_ptp)
+		clk_prepare_enable(fep->clk_ptp);
 	if (netif_running(ndev)) {
 		fec_restart(ndev, fep->full_duplex);
 		netif_device_attach(ndev);
-- 
1.8.1.2
