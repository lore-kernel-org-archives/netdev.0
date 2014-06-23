From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/22] micrel: Use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 06:41:40 -0700
Message-ID: <7f22701a1859d526b160d14b0969dde9ba598ad7.1403530604.git.joe@perches.com>
References: <cover.1403530604.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1403530604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the now unnecessary memset too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/micrel/ksz884x.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 064a48d..cd5f106 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4409,14 +4409,13 @@ static int ksz_alloc_desc(struct dev_info *adapter)
 		DESC_ALIGNMENT;
 
 	adapter->desc_pool.alloc_virt =
-		pci_alloc_consistent(
-			adapter->pdev, adapter->desc_pool.alloc_size,
-			&adapter->desc_pool.dma_addr);
+		pci_zalloc_consistent(adapter->pdev,
+				      adapter->desc_pool.alloc_size,
+				      &adapter->desc_pool.dma_addr);
 	if (adapter->desc_pool.alloc_virt == NULL) {
 		adapter->desc_pool.alloc_size = 0;
 		return 1;
 	}
-	memset(adapter->desc_pool.alloc_virt, 0, adapter->desc_pool.alloc_size);
 
 	/* Align to the next cache line boundary. */
 	offset = (((ulong) adapter->desc_pool.alloc_virt % DESC_ALIGNMENT) ?
-- 
1.8.1.2.459.gbcd45b4.dirty
