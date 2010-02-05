From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] mlx4: replace the dma_sync_single_range_for_cpu/device API
Date: Fri, 5 Feb 2010 13:57:42 +0900
Message-ID: <20100205135626G.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rolandd@cisco.com, eli@mellanox.co.il,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:44887 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932382Ab0BEE7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 23:59:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are only two users of the dma_sync_single_range_for_cpu/device
API in mainline (mlx4 and ssb). The
dma_sync_single_range_for_cpu/device API has never been documented and
the dma_sync_single_for_cpu/device API also support a partial sync.

This converts mlx4 to use the dma_sync_single_for_cpu/device API
(preparations for the removal of the dma_sync_single_range_for_cpu/device API).

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/mlx4/en_rx.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 829b9ec..6439464 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -508,11 +508,11 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		/* We are copying all relevant data to the skb - temporarily
 		 * synch buffers for the copy */
 		dma = be64_to_cpu(rx_desc->data[0].addr);
-		dma_sync_single_range_for_cpu(&mdev->pdev->dev, dma, 0,
-					      length, DMA_FROM_DEVICE);
+		dma_sync_single_for_cpu(&mdev->pdev->dev, dma, length,
+					DMA_FROM_DEVICE);
 		skb_copy_to_linear_data(skb, va, length);
-		dma_sync_single_range_for_device(&mdev->pdev->dev, dma, 0,
-						 length, DMA_FROM_DEVICE);
+		dma_sync_single_for_device(&mdev->pdev->dev, dma, length,
+					   DMA_FROM_DEVICE);
 		skb->tail += length;
 	} else {
 
-- 
1.5.6.5

