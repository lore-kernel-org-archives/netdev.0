From: Joe Perches <joe@perches.com>
Subject: [PATCH -next 13/26] ath: Use dma_zalloc_coherent
Date: Sun, 15 Jun 2014 13:37:42 -0700
Message-ID: <55b103a2ec78c0031b348e103603bf9a0d9cac3b.1402863905.git.joe@perches.com>
References: <cover.1402863904.git.joe@perches.com>
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, wcn36xx@lists.infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1402863904.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the zeroing function instead of dma_alloc_coherent & memset(,0,)

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath10k/pci.c  | 8 ++------
 drivers/net/wireless/ath/ath10k/wmi.c  | 8 ++------
 drivers/net/wireless/ath/wcn36xx/dxe.c | 6 ++----
 3 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index d0004d5..35045a4 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -359,16 +359,12 @@ static int ath10k_pci_diag_read_mem(struct ath10k *ar, u32 address, void *data,
 	 *   2) Buffer in DMA-able space
 	 */
 	orig_nbytes = nbytes;
-	data_buf = (unsigned char *)dma_alloc_coherent(ar->dev,
-						       orig_nbytes,
-						       &ce_data_base,
-						       GFP_ATOMIC);
-
+	data_buf = dma_zalloc_coherent(ar->dev, orig_nbytes, &ce_data_base,
+				       GFP_ATOMIC);
 	if (!data_buf) {
 		ret = -ENOMEM;
 		goto done;
 	}
-	memset(data_buf, 0, orig_nbytes);
 
 	remaining_bytes = orig_nbytes;
 	ce_data = ce_data_base;
diff --git a/drivers/net/wireless/ath/ath10k/wmi.c b/drivers/net/wireless/ath/ath10k/wmi.c
index 4b7782a..0093269 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.c
+++ b/drivers/net/wireless/ath/ath10k/wmi.c
@@ -1889,17 +1889,13 @@ static int ath10k_wmi_alloc_host_mem(struct ath10k *ar, u32 req_id,
 	if (!pool_size)
 		return -EINVAL;
 
-	ar->wmi.mem_chunks[idx].vaddr = dma_alloc_coherent(ar->dev,
-							   pool_size,
-							   &paddr,
-							   GFP_ATOMIC);
+	ar->wmi.mem_chunks[idx].vaddr = dma_zalloc_coherent(ar->dev, pool_size,
+							    &paddr, GFP_ATOMIC);
 	if (!ar->wmi.mem_chunks[idx].vaddr) {
 		ath10k_warn("failed to allocate memory chunk\n");
 		return -ENOMEM;
 	}
 
-	memset(ar->wmi.mem_chunks[idx].vaddr, 0, pool_size);
-
 	ar->wmi.mem_chunks[idx].paddr = paddr;
 	ar->wmi.mem_chunks[idx].len = pool_size;
 	ar->wmi.mem_chunks[idx].req_id = req_id;
diff --git a/drivers/net/wireless/ath/wcn36xx/dxe.c b/drivers/net/wireless/ath/wcn36xx/dxe.c
index 73f12f1..1975a1a 100644
--- a/drivers/net/wireless/ath/wcn36xx/dxe.c
+++ b/drivers/net/wireless/ath/wcn36xx/dxe.c
@@ -177,13 +177,11 @@ static int wcn36xx_dxe_init_descs(struct wcn36xx_dxe_ch *wcn_ch)
 	int i;
 
 	size = wcn_ch->desc_num * sizeof(struct wcn36xx_dxe_desc);
-	wcn_ch->cpu_addr = dma_alloc_coherent(NULL, size, &wcn_ch->dma_addr,
-					      GFP_KERNEL);
+	wcn_ch->cpu_addr = dma_zalloc_coherent(NULL, size, &wcn_ch->dma_addr,
+					       GFP_KERNEL);
 	if (!wcn_ch->cpu_addr)
 		return -ENOMEM;
 
-	memset(wcn_ch->cpu_addr, 0, size);
-
 	cur_dxe = (struct wcn36xx_dxe_desc *)wcn_ch->cpu_addr;
 	cur_ctl = wcn_ch->head_blk_ctl;
 
-- 
1.8.1.2.459.gbcd45b4.dirty
