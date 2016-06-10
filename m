From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: cpsw: use destroy ctlr to destroy channels
Date: Sat, 11 Jun 2016 01:11:54 +0300
Message-ID: <1465596714-26697-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no reason to destroy channels that are destroyed while
cpdma_ctlr destroy. In this case no need to remember how much
channels where created and destroy them by one, as cpdma_ctlr
destroys all of them.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---

Based on master

 drivers/net/ethernet/ti/cpsw.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e6bb0ec..5319089 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2505,8 +2505,6 @@ static int cpsw_probe(struct platform_device *pdev)
 clean_ale_ret:
 	cpsw_ale_destroy(priv->ale);
 clean_dma_ret:
-	cpdma_chan_destroy(priv->txch);
-	cpdma_chan_destroy(priv->rxch);
 	cpdma_ctlr_destroy(priv->dma);
 clean_runtime_disable_ret:
 	pm_runtime_disable(&pdev->dev);
@@ -2534,8 +2532,6 @@ static int cpsw_remove(struct platform_device *pdev)
 	unregister_netdev(ndev);
 
 	cpsw_ale_destroy(priv->ale);
-	cpdma_chan_destroy(priv->txch);
-	cpdma_chan_destroy(priv->rxch);
 	cpdma_ctlr_destroy(priv->dma);
 	pm_runtime_disable(&pdev->dev);
 	device_for_each_child(&pdev->dev, NULL, cpsw_remove_child_device);
-- 
1.9.1
