From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 3/3] drivers: net: cpsw: remove child devices while driver detach
Date: Mon, 13 Oct 2014 22:21:07 +0530
Message-ID: <1413219067-15328-4-git-send-email-mugunthanvnm@ti.com>
References: <1413219067-15328-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:41676 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754159AbaJMQvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2014 12:51:21 -0400
In-Reply-To: <1413219067-15328-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove all the child devices from the system to make sure that re-insert of
cpsw module doesn't fail on child device populated by of_platform_populate().

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index ab167dc..952e1e4 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2392,6 +2392,15 @@ clean_ndev_ret:
 	return ret;
 }
 
+static int cpsw_remove_child_device(struct device *dev, void *c)
+{
+	struct platform_device *pdev = to_platform_device(dev);
+
+	of_device_unregister(pdev);
+
+	return 0;
+}
+
 static int cpsw_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
@@ -2406,6 +2415,7 @@ static int cpsw_remove(struct platform_device *pdev)
 	cpdma_chan_destroy(priv->rxch);
 	cpdma_ctlr_destroy(priv->dma);
 	pm_runtime_disable(&pdev->dev);
+	device_for_each_child(&pdev->dev, NULL, cpsw_remove_child_device);
 	if (priv->data.dual_emac)
 		free_netdev(cpsw_get_slave_ndev(priv, 1));
 	free_netdev(ndev);
-- 
2.1.1.332.g0bf7dd6
