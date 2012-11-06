From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 7/7] net: cpsw: halt network stack before halting the device
 during suspend
Date: Tue, 6 Nov 2012 13:42:25 +0530
Message-ID: <1352189545-26303-8-git-send-email-mugunthanvnm@ti.com>
References: <1352189545-26303-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>, devicetree-discuss@lists.ozlabs.org,
 linux-omap@vger.kernel.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1352189545-26303-1-git-send-email-mugunthanvnm@ti.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Move network stack halt APIs before halting the hardware to ensure no
packets are queued to hardware during closing the device during
suspend sequence.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
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
