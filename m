From: Joe Perches <joe@perches.com>
Subject: [PATCH 32/49] drivers/net/bnx2.c: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:56 -0700
Message-ID: <d7426ed19adf82783f1cf87cd95637594f3f2e40.1288925425.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bnx2.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 062600b..aba4d0f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -766,13 +766,10 @@ bnx2_alloc_rx_mem(struct bnx2 *bp)
 		int j;
 
 		rxr->rx_buf_ring =
-			vmalloc(SW_RXBD_RING_SIZE * bp->rx_max_ring);
+			vzalloc(SW_RXBD_RING_SIZE * bp->rx_max_ring);
 		if (rxr->rx_buf_ring == NULL)
 			return -ENOMEM;
 
-		memset(rxr->rx_buf_ring, 0,
-		       SW_RXBD_RING_SIZE * bp->rx_max_ring);
-
 		for (j = 0; j < bp->rx_max_ring; j++) {
 			rxr->rx_desc_ring[j] =
 				dma_alloc_coherent(&bp->pdev->dev,
@@ -785,13 +782,10 @@ bnx2_alloc_rx_mem(struct bnx2 *bp)
 		}
 
 		if (bp->rx_pg_ring_size) {
-			rxr->rx_pg_ring = vmalloc(SW_RXPG_RING_SIZE *
+			rxr->rx_pg_ring = vzalloc(SW_RXPG_RING_SIZE *
 						  bp->rx_max_pg_ring);
 			if (rxr->rx_pg_ring == NULL)
 				return -ENOMEM;
-
-			memset(rxr->rx_pg_ring, 0, SW_RXPG_RING_SIZE *
-			       bp->rx_max_pg_ring);
 		}
 
 		for (j = 0; j < bp->rx_max_pg_ring; j++) {
-- 
1.7.3.1.g432b3.dirty
