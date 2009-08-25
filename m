From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/9] s2io.c: Use calculated size in kmallocs
Date: Mon, 24 Aug 2009 20:29:42 -0700
Message-ID: <7b9b5a99f982358f09b83e2100217d9d1d7bf3b3.1251170438.git.joe@perches.com>
References: <cover.1251170438.git.joe@perches.com>
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use consistent style.  Don't calculate the kmalloc size multiple times

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/s2io.c |   63 +++++++++++++++++++++++----------------------------
 1 files changed, 28 insertions(+), 35 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index b6bd3c8..75f2209 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -823,15 +823,15 @@ static int init_shared_mem(struct s2io_nic *nic)
 			}
 			mem_allocated += size;
 			memset(tmp_v_addr, 0, size);
+
+			size = sizeof(struct rxd_info) *
+				rxd_count[nic->rxd_mode];
 			rx_blocks->block_virt_addr = tmp_v_addr;
 			rx_blocks->block_dma_addr = tmp_p_addr;
-			rx_blocks->rxds = kmalloc(sizeof(struct rxd_info)*
-						  rxd_count[nic->rxd_mode],
-						  GFP_KERNEL);
+			rx_blocks->rxds = kmalloc(size,  GFP_KERNEL);
 			if (!rx_blocks->rxds)
 				return -ENOMEM;
-			mem_allocated +=
-			(sizeof(struct rxd_info)* rxd_count[nic->rxd_mode]);
+			mem_allocated += size;
 			for (l=0; l<rxd_count[nic->rxd_mode];l++) {
 				rx_blocks->rxds[l].virt_addr =
 					rx_blocks->block_virt_addr +
@@ -867,41 +867,37 @@ static int init_shared_mem(struct s2io_nic *nic)
 
 			blk_cnt = rx_cfg->num_rxd /
 				(rxd_count[nic->rxd_mode]+ 1);
-			ring->ba = kmalloc((sizeof(struct buffAdd *) * blk_cnt),
-					   GFP_KERNEL);
+			size = sizeof(struct buffAdd *) * blk_cnt;
+			ring->ba = kmalloc(size, GFP_KERNEL);
 			if (!ring->ba)
 				return -ENOMEM;
-			mem_allocated +=(sizeof(struct buffAdd *) * blk_cnt);
+			mem_allocated += size;
 			for (j = 0; j < blk_cnt; j++) {
 				int k = 0;
-				ring->ba[j] =
-					kmalloc((sizeof(struct buffAdd) *
-						(rxd_count[nic->rxd_mode] + 1)),
-						GFP_KERNEL);
+
+				size = sizeof(struct buffAdd) *
+					(rxd_count[nic->rxd_mode] + 1);
+				ring->ba[j] = kmalloc(size, GFP_KERNEL);
 				if (!ring->ba[j])
 					return -ENOMEM;
-				mem_allocated += (sizeof(struct buffAdd) *  \
-					(rxd_count[nic->rxd_mode] + 1));
+				mem_allocated += size;
 				while (k != rxd_count[nic->rxd_mode]) {
 					ba = &ring->ba[j][k];
-
-					ba->ba_0_org = (void *) kmalloc
-					    (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
+					size = BUF0_LEN + ALIGN_SIZE;
+					ba->ba_0_org = kmalloc(size, GFP_KERNEL);
 					if (!ba->ba_0_org)
 						return -ENOMEM;
-					mem_allocated +=
-						(BUF0_LEN + ALIGN_SIZE);
+					mem_allocated += size;
 					tmp = (unsigned long)ba->ba_0_org;
 					tmp += ALIGN_SIZE;
 					tmp &= ~((unsigned long) ALIGN_SIZE);
 					ba->ba_0 = (void *) tmp;
 
-					ba->ba_1_org = (void *) kmalloc
-					    (BUF1_LEN + ALIGN_SIZE, GFP_KERNEL);
+					size = BUF1_LEN + ALIGN_SIZE;
+					ba->ba_1_org = kmalloc(size, GFP_KERNEL);
 					if (!ba->ba_1_org)
 						return -ENOMEM;
-					mem_allocated
-						+= (BUF1_LEN + ALIGN_SIZE);
+					mem_allocated += size;
 					tmp = (unsigned long) ba->ba_1_org;
 					tmp += ALIGN_SIZE;
 					tmp &= ~((unsigned long) ALIGN_SIZE);
@@ -3835,23 +3831,22 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	u64 rx_mat;
 	u16 msi_control; /* Temp variable */
 	int ret, i, j, msix_indx = 1;
+	int size;
 
-	nic->entries = kmalloc(nic->num_entries * sizeof(struct msix_entry),
-			       GFP_KERNEL);
+	size = nic->num_entries * sizeof(struct msix_entry);
+	nic->entries = kmalloc(size, GFP_KERNEL);
 	if (!nic->entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
 			__func__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return -ENOMEM;
 	}
-	nic->mac_control.stats_info->sw_stat.mem_allocated
-		+= (nic->num_entries * sizeof(struct msix_entry));
+	nic->mac_control.stats_info->sw_stat.mem_allocated += size;
 
-	memset(nic->entries, 0, nic->num_entries * sizeof(struct msix_entry));
+	memset(nic->entries, 0, size);
 
-	nic->s2io_entries =
-		kmalloc(nic->num_entries * sizeof(struct s2io_msix_entry),
-				   GFP_KERNEL);
+	size = nic->num_entries * sizeof(struct s2io_msix_entry);
+	nic->s2io_entries = kmalloc(size, GFP_KERNEL);
 	if (!nic->s2io_entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
 			__func__);
@@ -3861,10 +3856,8 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 			+= (nic->num_entries * sizeof(struct msix_entry));
 		return -ENOMEM;
 	}
-	 nic->mac_control.stats_info->sw_stat.mem_allocated
-		+= (nic->num_entries * sizeof(struct s2io_msix_entry));
-	memset(nic->s2io_entries, 0,
-		nic->num_entries * sizeof(struct s2io_msix_entry));
+	nic->mac_control.stats_info->sw_stat.mem_allocated += size;
+	memset(nic->s2io_entries, 0, size);
 
 	nic->entries[0].entry = 0;
 	nic->s2io_entries[0].entry = 0;
-- 
1.6.3.1.10.g659a0.dirty
