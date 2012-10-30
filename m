From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] net/at91_ether: fix the use of macb structure
Date: Tue, 30 Oct 2012 12:30:28 +0100
Message-ID: <1351596628-3405-1-git-send-email-nicolas.ferre@atmel.com>
References: <75eb5df193c504e68ebff7d6a6a88d9a1cc678cb.1351591858.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>,
	<linux-arm-kernel@lists.infradead.org>, <plagnioj@jcrosoft.com>,
	<patrice.vilchez@atmel.com>, <linux-kernel@vger.kernel.org>,
	<manabian@gmail.com>, Nicolas Ferre <nicolas.ferre@atmel.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <75eb5df193c504e68ebff7d6a6a88d9a1cc678cb.1351591858.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to the use of common structure in at91_ether and macb drivers,
change the name of DMA descriptor structures in at91_ether as well:
dma_desc => macb_dma_desc

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
Hi,

This patch is a fix for the patch
[PATCH v3 06/10] net/macb: clean up ring buffer logic
that I have just sent.

I would prefer to merge it with the patch mentioned above
that introduces the issue. Tell me if you do it or if I
have to provide a v4 for this patch series.

 drivers/net/ethernet/cadence/at91_ether.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index b92815a..0d6392d 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -156,7 +156,7 @@ static int at91ether_start(struct net_device *dev)
 	int i;
 
 	lp->rx_ring = dma_alloc_coherent(&lp->pdev->dev,
-					MAX_RX_DESCR * sizeof(struct dma_desc),
+					MAX_RX_DESCR * sizeof(struct macb_dma_desc),
 					&lp->rx_ring_dma, GFP_KERNEL);
 	if (!lp->rx_ring) {
 		netdev_err(lp->dev, "unable to alloc rx ring DMA buffer\n");
@@ -170,7 +170,7 @@ static int at91ether_start(struct net_device *dev)
 		netdev_err(lp->dev, "unable to alloc rx data DMA buffer\n");
 
 		dma_free_coherent(&lp->pdev->dev,
-					MAX_RX_DESCR * sizeof(struct dma_desc),
+					MAX_RX_DESCR * sizeof(struct macb_dma_desc),
 					lp->rx_ring, lp->rx_ring_dma);
 		lp->rx_ring = NULL;
 		return -ENOMEM;
@@ -256,7 +256,7 @@ static int at91ether_close(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	dma_free_coherent(&lp->pdev->dev,
-				MAX_RX_DESCR * sizeof(struct dma_desc),
+				MAX_RX_DESCR * sizeof(struct macb_dma_desc),
 				lp->rx_ring, lp->rx_ring_dma);
 	lp->rx_ring = NULL;
 
-- 
1.8.0
