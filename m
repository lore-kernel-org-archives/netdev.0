From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH 1/1] net: fec: convert to clk_prepare/clk_unprepare
Date: Thu, 10 Nov 2011 13:01:44 +0800
Message-ID: <1320901304-13157-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<kernel@pengutronix.de>, <shawn.guo@linaro.org>,
	<eric.miao@linaro.org>, Richard Zhao <richard.zhao@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:32830
	"EHLO DB3EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751379Ab1KJFCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 00:02:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 1124ce0..92e3585 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1588,6 +1588,7 @@ fec_probe(struct platform_device *pdev)
 		ret = PTR_ERR(fep->clk);
 		goto failed_clk;
 	}
+	clk_prepare(fep->clk);
 	clk_enable(fep->clk);
 
 	ret = fec_enet_init(ndev);
@@ -1612,6 +1613,7 @@ failed_register:
 failed_mii_init:
 failed_init:
 	clk_disable(fep->clk);
+	clk_unprepare(fep->clk);
 	clk_put(fep->clk);
 failed_clk:
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
@@ -1639,6 +1641,7 @@ fec_drv_remove(struct platform_device *pdev)
 	fec_stop(ndev);
 	fec_enet_mii_remove(fep);
 	clk_disable(fep->clk);
+	clk_unprepare(fep->clk);
 	clk_put(fep->clk);
 	iounmap(fep->hwp);
 	unregister_netdev(ndev);
@@ -1665,6 +1668,7 @@ fec_suspend(struct device *dev)
 		netif_device_detach(ndev);
 	}
 	clk_disable(fep->clk);
+	clk_unprepare(fep->clk);
 
 	return 0;
 }
@@ -1675,6 +1679,7 @@ fec_resume(struct device *dev)
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	clk_prepare(fep->clk);
 	clk_enable(fep->clk);
 	if (netif_running(ndev)) {
 		fec_restart(ndev, fep->full_duplex);
-- 
1.7.5.4
