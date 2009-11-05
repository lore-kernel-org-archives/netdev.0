From: Ranjith Lohithakshan <ranjithl@ti.com>
Subject: [PATCH v2] TI DaVinci EMAC: Add suspend/resume capability
Date: Thu,  5 Nov 2009 10:11:17 +0530
Message-ID: <1257396077-26882-1-git-send-email-ranjithl@ti.com>
Cc: davem@davemloft.net,
	davinci-linux-open-source@linux.davincidsp.com,
	Ranjith Lohithakshan <ranjithl@ti.com>,
	Chaithrika U S <chaithrika@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:49335 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754206AbZKEEvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 23:51:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add suspend/resume capability to TI DaVinci EMAC driver.

Signed-off-by: Ranjith Lohithakshan <ranjithl@ti.com>
Signed-off-by: Chaithrika U S <chaithrika@ti.com>
---
Applies to net-next-2.6

 drivers/net/davinci_emac.c |   30 +++++++++++++++++++++++++++---
 1 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index a876dce..f1b09c0 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2806,11 +2806,33 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static
+int davinci_emac_suspend(struct platform_device *pdev, pm_message_t state)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	if (netif_running(dev))
+		emac_dev_stop(dev);
+
+	clk_disable(emac_clk);
+
+	return 0;
+}
+
+static int davinci_emac_resume(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	clk_enable(emac_clk);
+
+	if (netif_running(dev))
+		emac_dev_open(dev);
+
+	return 0;
+}
+
 /**
  * davinci_emac_driver: EMAC platform driver structure
- *
- * We implement only probe and remove functions - suspend/resume and
- * others not supported by this module
  */
 static struct platform_driver davinci_emac_driver = {
 	.driver = {
@@ -2819,6 +2841,8 @@ static struct platform_driver davinci_emac_driver = {
 	},
 	.probe = davinci_emac_probe,
 	.remove = __devexit_p(davinci_emac_remove),
+	.suspend = davinci_emac_suspend,
+	.resume = davinci_emac_resume,
 };
 
 /**
-- 
1.5.6

