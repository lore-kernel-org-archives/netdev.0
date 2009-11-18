From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.32] cxgb3: fix premature page unmap
Date: Tue, 17 Nov 2009 18:38:28 -0800
Message-ID: <20091118023828.16411.57681.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755571AbZKRCi0@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

unmap Rx page only when guaranteed that this page won't be
used anymore to allocate rx page chunks.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index f866128..6366061 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -879,7 +879,7 @@ recycle:
 	pci_dma_sync_single_for_cpu(adap->pdev, dma_addr, len,
 				    PCI_DMA_FROMDEVICE);
 	(*sd->pg_chunk.p_cnt)--;
-	if (!*sd->pg_chunk.p_cnt)
+	if (!*sd->pg_chunk.p_cnt && sd->pg_chunk.page != fl->pg_chunk.page)
 		pci_unmap_page(adap->pdev,
 			       sd->pg_chunk.mapping,
 			       fl->alloc_size,
@@ -2088,7 +2088,7 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 				    PCI_DMA_FROMDEVICE);
 
 	(*sd->pg_chunk.p_cnt)--;
-	if (!*sd->pg_chunk.p_cnt)
+	if (!*sd->pg_chunk.p_cnt && sd->pg_chunk.page != fl->pg_chunk.page)
 		pci_unmap_page(adap->pdev,
 			       sd->pg_chunk.mapping,
 			       fl->alloc_size,
