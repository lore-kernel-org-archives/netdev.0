From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/22] atl1e: Use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 06:41:37 -0700
Message-ID: <f5d819ba5c42a3379c94bef8a95410bdd2a88360.1403530604.git.joe@perches.com>
References: <cover.1403530604.git.joe@perches.com>
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1403530604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the now unnecessary memset too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 4345332..316e0c3 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -831,17 +831,14 @@ static int atl1e_setup_ring_resources(struct atl1e_adapter *adapter)
 	/* real ring DMA buffer */
 
 	size = adapter->ring_size;
-	adapter->ring_vir_addr = pci_alloc_consistent(pdev,
-			adapter->ring_size, &adapter->ring_dma);
-
+	adapter->ring_vir_addr = pci_zalloc_consistent(pdev, adapter->ring_size,
+						       &adapter->ring_dma);
 	if (adapter->ring_vir_addr == NULL) {
 		netdev_err(adapter->netdev,
 			   "pci_alloc_consistent failed, size = D%d\n", size);
 		return -ENOMEM;
 	}
 
-	memset(adapter->ring_vir_addr, 0, adapter->ring_size);
-
 	rx_page_desc = rx_ring->rx_page_desc;
 
 	/* Init TPD Ring */
-- 
1.8.1.2.459.gbcd45b4.dirty
