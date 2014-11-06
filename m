From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 1/2] amd-xgbe: Free channel/ring structures later
Date: Thu, 6 Nov 2014 17:02:13 -0600
Message-ID: <20141106230213.21973.14781.stgit@tlendack-t1.amdoffice.net>
References: <20141106230207.21973.67338.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0112.outbound.protection.outlook.com ([157.56.110.112]:20131
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753232AbaKFXQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2014 18:16:35 -0500
In-Reply-To: <20141106230207.21973.67338.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The channel structure is freed before freeing the per channel
interrupts resulting in a kernel oops. Move the call to free
the channel structure to after the freeing of the per channel
interrupts.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index ced9f52..ec5fff3 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1369,9 +1369,6 @@ static int xgbe_close(struct net_device *netdev)
 	/* Free the ring descriptors and buffers */
 	desc_if->free_ring_resources(pdata);
 
-	/* Free the channel and ring structures */
-	xgbe_free_channels(pdata);
-
 	/* Release the interrupts */
 	devm_free_irq(pdata->dev, pdata->dev_irq, pdata);
 	if (pdata->per_channel_irq) {
@@ -1380,6 +1377,9 @@ static int xgbe_close(struct net_device *netdev)
 			devm_free_irq(pdata->dev, channel->dma_irq, channel);
 	}
 
+	/* Free the channel and ring structures */
+	xgbe_free_channels(pdata);
+
 	/* Disable the clocks */
 	clk_disable_unprepare(pdata->ptpclk);
 	clk_disable_unprepare(pdata->sysclk);
