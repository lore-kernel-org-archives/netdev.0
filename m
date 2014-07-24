From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH v2 net-next] fec: Simplify the PM related hooks
Date: Thu, 24 Jul 2014 18:24:01 -0300
Message-ID: <1406237041-29468-1-git-send-email-festevam@gmail.com>
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:41362 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759583AbaGXVYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 17:24:17 -0400
Received: by mail-yh0-f53.google.com with SMTP id c41so2307898yho.40
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 14:24:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Get rid of the CONFIG_PM_SLEEP ifdef by annotating the suspend/resume functions
with '__maybe_unused' in order to keep the code simpler and shorter.

While at it, declare the suspend/resume functions in a single line.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1:
- Fix typo in commit log

 drivers/net/ethernet/freescale/fec_main.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e0efb21..66fe1f6 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2696,9 +2696,7 @@ fec_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM_SLEEP
-static int
-fec_suspend(struct device *dev)
+static int __maybe_unused fec_suspend(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
@@ -2723,8 +2721,7 @@ fec_suspend(struct device *dev)
 	return 0;
 }
 
-static int
-fec_resume(struct device *dev)
+static int __maybe_unused fec_resume(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
@@ -2759,7 +2756,6 @@ failed_clk:
 		regulator_disable(fep->reg_phy);
 	return ret;
 }
-#endif /* CONFIG_PM_SLEEP */
 
 static SIMPLE_DEV_PM_OPS(fec_pm_ops, fec_suspend, fec_resume);
 
-- 
1.8.3.2
