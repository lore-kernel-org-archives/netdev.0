From: Vinod Koul <vinod.koul@intel.com>
Subject: [PATCH 06/12] net: ks8842: use dmaengine_terminate_all() API
Date: Sat, 11 Oct 2014 21:10:34 +0530
Message-ID: <1413042040-28222-6-git-send-email-vinod.koul@intel.com>
References: <1413041973-28146-1-git-send-email-vinod.koul@intel.com>
Cc: Vinod Koul <vinod.koul@intel.com>, Mark Brown <broonie@linaro.org>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Dan Williams <dan.j.williams@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dmaengine@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413041973-28146-1-git-send-email-vinod.koul@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The drivers should use dmaengine_terminate_all() API instead of
accessing the device_control which will be deprecated soon

Signed-off-by: Vinod Koul <vinod.koul@intel.com>
---
 drivers/net/ethernet/micrel/ks8842.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index 822616e..0c33b92 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -875,13 +875,11 @@ static void ks8842_stop_dma(struct ks8842_adapter *adapter)
 
 	tx_ctl->adesc = NULL;
 	if (tx_ctl->chan)
-		tx_ctl->chan->device->device_control(tx_ctl->chan,
-			DMA_TERMINATE_ALL, 0);
+		dmaengine_terminate_all(tx_ctl->chan);
 
 	rx_ctl->adesc = NULL;
 	if (rx_ctl->chan)
-		rx_ctl->chan->device->device_control(rx_ctl->chan,
-			DMA_TERMINATE_ALL, 0);
+		dmaengine_terminate_all(rx_ctl->chan);
 
 	if (sg_dma_address(&rx_ctl->sg))
 		dma_unmap_single(adapter->dev, sg_dma_address(&rx_ctl->sg),
-- 
1.7.0.4
