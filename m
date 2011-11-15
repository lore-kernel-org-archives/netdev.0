From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH V4 12/14] net: fec: add clk_prepare/clk_unprepare
Date: Tue, 15 Nov 2011 14:48:07 +0800
Message-ID: <1321339689-25256-13-git-send-email-richard.zhao@linaro.org>
References: <1321339689-25256-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux@arm.linux.org.uk>, <amit.kucheria@canonical.com>,
	<kernel@pengutronix.de>, <ben-linux@fluff.org>, <cjb@laptop.org>,
	<alan@linux.intel.com>, <eric.miao@linaro.org>,
	<richard.zhao@linaro.org>
To: <linux-arm-kernel@lists.infradead.org>,
	<linux-i2c@vger.kernel.org>, <linux-mmc@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-serial@vger.kernel.org>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1321339689-25256-1-git-send-email-richard.zhao@linaro.org>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's for migrating to generic clk framework API.

Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 1124ce0..e96fa44 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1588,7 +1588,7 @@ fec_probe(struct platform_device *pdev)
 		ret = PTR_ERR(fep->clk);
 		goto failed_clk;
 	}
-	clk_enable(fep->clk);
+	clk_prepare_enable(fep->clk);
 
 	ret = fec_enet_init(ndev);
 	if (ret)
@@ -1611,7 +1611,7 @@ failed_register:
 	fec_enet_mii_remove(fep);
 failed_mii_init:
 failed_init:
-	clk_disable(fep->clk);
+	clk_disable_unprepare(fep->clk);
 	clk_put(fep->clk);
 failed_clk:
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
@@ -1638,7 +1638,7 @@ fec_drv_remove(struct platform_device *pdev)
 
 	fec_stop(ndev);
 	fec_enet_mii_remove(fep);
-	clk_disable(fep->clk);
+	clk_disable_unprepare(fep->clk);
 	clk_put(fep->clk);
 	iounmap(fep->hwp);
 	unregister_netdev(ndev);
@@ -1664,7 +1664,7 @@ fec_suspend(struct device *dev)
 		fec_stop(ndev);
 		netif_device_detach(ndev);
 	}
-	clk_disable(fep->clk);
+	clk_disable_unprepare(fep->clk);
 
 	return 0;
 }
@@ -1675,7 +1675,7 @@ fec_resume(struct device *dev)
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
-	clk_enable(fep->clk);
+	clk_prepare_enable(fep->clk);
 	if (netif_running(ndev)) {
 		fec_restart(ndev, fep->full_duplex);
 		netif_device_attach(ndev);
-- 
1.7.5.4


