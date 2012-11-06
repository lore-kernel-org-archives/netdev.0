From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH V4 7/7] net: cpsw: halt network stack before halting the device during suspend
Date: Tue, 6 Nov 2012 23:02:39 +0530
Message-ID: <1352223159-27504-8-git-send-email-mugunthanvnm@ti.com>
References: <1352223159-27504-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:41020 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394Ab2KFRdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2012 12:33:00 -0500
In-Reply-To: <1352223159-27504-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move network stack halt APIs before halting the hardware to ensure no
packets are queued to hardware during closing the device during
suspend sequence.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f94aa8f..b46dbb4 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -698,12 +698,12 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
 	cpsw_info(priv, ifdown, "shutting down cpsw device\n");
-	cpsw_intr_disable(priv);
-	cpdma_ctlr_int_ctrl(priv->dma, false);
-	cpdma_ctlr_stop(priv->dma);
 	netif_stop_queue(priv->ndev);
 	napi_disable(&priv->napi);
 	netif_carrier_off(priv->ndev);
+	cpsw_intr_disable(priv);
+	cpdma_ctlr_int_ctrl(priv->dma, false);
+	cpdma_ctlr_stop(priv->dma);
 	cpsw_ale_stop(priv->ale);
 	for_each_slave(priv, cpsw_slave_stop, priv);
 	pm_runtime_put_sync(&priv->pdev->dev);
-- 
1.7.0.4
