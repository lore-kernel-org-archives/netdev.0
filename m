From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] qla3xxx: use the DMA state API instead of the pci equivalents
Date: Tue, 13 Apr 2010 09:32:13 +0900
Message-ID: <1271118734-28353-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: fujita.tomonori@lab.ntt.co.jp, Ron Mercer <ron.mercer@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38868 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754428Ab0DMAdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 20:33:33 -0400
In-Reply-To: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replace the PCI DMA state API (include/linux/pci-dma.h) with the
DMA equivalents since the PCI DMA state API will be obsolete.

No functional change.

For further information about the background:

http://marc.info/?l=linux-netdev&m=127037540020276&w=2

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc:  Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   64 ++++++++++++++++++++++++------------------------
 drivers/net/qla3xxx.h |    8 +++---
 2 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index fc11ad3..01a6ca3 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -343,8 +343,8 @@ static void ql_release_to_lrg_buf_free_list(struct ql3_adapter *qdev,
 			    cpu_to_le32(LS_64BITS(map));
 			lrg_buf_cb->buf_phy_addr_high =
 			    cpu_to_le32(MS_64BITS(map));
-			pci_unmap_addr_set(lrg_buf_cb, mapaddr, map);
-			pci_unmap_len_set(lrg_buf_cb, maplen,
+			dma_unmap_addr_set(lrg_buf_cb, mapaddr, map);
+			dma_unmap_len_set(lrg_buf_cb, maplen,
 					  qdev->lrg_buffer_len -
 					  QL_HEADER_SPACE);
 		}
@@ -1924,8 +1924,8 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
 				    cpu_to_le32(LS_64BITS(map));
 				lrg_buf_cb->buf_phy_addr_high =
 				    cpu_to_le32(MS_64BITS(map));
-				pci_unmap_addr_set(lrg_buf_cb, mapaddr, map);
-				pci_unmap_len_set(lrg_buf_cb, maplen,
+				dma_unmap_addr_set(lrg_buf_cb, mapaddr, map);
+				dma_unmap_len_set(lrg_buf_cb, maplen,
 						  qdev->lrg_buffer_len -
 						  QL_HEADER_SPACE);
 				--qdev->lrg_buf_skb_check;
@@ -2041,16 +2041,16 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 	}
 
 	pci_unmap_single(qdev->pdev,
-			 pci_unmap_addr(&tx_cb->map[0], mapaddr),
-			 pci_unmap_len(&tx_cb->map[0], maplen),
+			 dma_unmap_addr(&tx_cb->map[0], mapaddr),
+			 dma_unmap_len(&tx_cb->map[0], maplen),
 			 PCI_DMA_TODEVICE);
 	tx_cb->seg_count--;
 	if (tx_cb->seg_count) {
 		for (i = 1; i < tx_cb->seg_count; i++) {
 			pci_unmap_page(qdev->pdev,
-				       pci_unmap_addr(&tx_cb->map[i],
+				       dma_unmap_addr(&tx_cb->map[i],
 						      mapaddr),
-				       pci_unmap_len(&tx_cb->map[i], maplen),
+				       dma_unmap_len(&tx_cb->map[i], maplen),
 				       PCI_DMA_TODEVICE);
 		}
 	}
@@ -2119,8 +2119,8 @@ static void ql_process_mac_rx_intr(struct ql3_adapter *qdev,
 
 	skb_put(skb, length);
 	pci_unmap_single(qdev->pdev,
-			 pci_unmap_addr(lrg_buf_cb2, mapaddr),
-			 pci_unmap_len(lrg_buf_cb2, maplen),
+			 dma_unmap_addr(lrg_buf_cb2, mapaddr),
+			 dma_unmap_len(lrg_buf_cb2, maplen),
 			 PCI_DMA_FROMDEVICE);
 	prefetch(skb->data);
 	skb->ip_summed = CHECKSUM_NONE;
@@ -2165,8 +2165,8 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 
 	skb_put(skb2, length);	/* Just the second buffer length here. */
 	pci_unmap_single(qdev->pdev,
-			 pci_unmap_addr(lrg_buf_cb2, mapaddr),
-			 pci_unmap_len(lrg_buf_cb2, maplen),
+			 dma_unmap_addr(lrg_buf_cb2, mapaddr),
+			 dma_unmap_len(lrg_buf_cb2, maplen),
 			 PCI_DMA_FROMDEVICE);
 	prefetch(skb2->data);
 
@@ -2454,8 +2454,8 @@ static int ql_send_map(struct ql3_adapter *qdev,
 	oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
 	oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
 	oal_entry->len = cpu_to_le32(len);
-	pci_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
-	pci_unmap_len_set(&tx_cb->map[seg], maplen, len);
+	dma_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
+	dma_unmap_len_set(&tx_cb->map[seg], maplen, len);
 	seg++;
 
 	if (seg_cnt == 1) {
@@ -2488,9 +2488,9 @@ static int ql_send_map(struct ql3_adapter *qdev,
 				oal_entry->len =
 				    cpu_to_le32(sizeof(struct oal) |
 						OAL_CONT_ENTRY);
-				pci_unmap_addr_set(&tx_cb->map[seg], mapaddr,
+				dma_unmap_addr_set(&tx_cb->map[seg], mapaddr,
 						   map);
-				pci_unmap_len_set(&tx_cb->map[seg], maplen,
+				dma_unmap_len_set(&tx_cb->map[seg], maplen,
 						  sizeof(struct oal));
 				oal_entry = (struct oal_entry *)oal;
 				oal++;
@@ -2512,8 +2512,8 @@ static int ql_send_map(struct ql3_adapter *qdev,
 			oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
 			oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
 			oal_entry->len = cpu_to_le32(frag->size);
-			pci_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
-			pci_unmap_len_set(&tx_cb->map[seg], maplen,
+			dma_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
+			dma_unmap_len_set(&tx_cb->map[seg], maplen,
 					  frag->size);
 		}
 		/* Terminate the last segment. */
@@ -2539,22 +2539,22 @@ map_error:
 		   (seg == 12 && seg_cnt > 13) ||      /* but necessary. */
 		   (seg == 17 && seg_cnt > 18)) {
 			pci_unmap_single(qdev->pdev,
-				pci_unmap_addr(&tx_cb->map[seg], mapaddr),
-				pci_unmap_len(&tx_cb->map[seg], maplen),
+				dma_unmap_addr(&tx_cb->map[seg], mapaddr),
+				dma_unmap_len(&tx_cb->map[seg], maplen),
 				 PCI_DMA_TODEVICE);
 			oal++;
 			seg++;
 		}
 
 		pci_unmap_page(qdev->pdev,
-			       pci_unmap_addr(&tx_cb->map[seg], mapaddr),
-			       pci_unmap_len(&tx_cb->map[seg], maplen),
+			       dma_unmap_addr(&tx_cb->map[seg], mapaddr),
+			       dma_unmap_len(&tx_cb->map[seg], maplen),
 			       PCI_DMA_TODEVICE);
 	}
 
 	pci_unmap_single(qdev->pdev,
-			 pci_unmap_addr(&tx_cb->map[0], mapaddr),
-			 pci_unmap_addr(&tx_cb->map[0], maplen),
+			 dma_unmap_addr(&tx_cb->map[0], mapaddr),
+			 dma_unmap_addr(&tx_cb->map[0], maplen),
 			 PCI_DMA_TODEVICE);
 
 	return NETDEV_TX_BUSY;
@@ -2841,8 +2841,8 @@ static void ql_free_large_buffers(struct ql3_adapter *qdev)
 		if (lrg_buf_cb->skb) {
 			dev_kfree_skb(lrg_buf_cb->skb);
 			pci_unmap_single(qdev->pdev,
-					 pci_unmap_addr(lrg_buf_cb, mapaddr),
-					 pci_unmap_len(lrg_buf_cb, maplen),
+					 dma_unmap_addr(lrg_buf_cb, mapaddr),
+					 dma_unmap_len(lrg_buf_cb, maplen),
 					 PCI_DMA_FROMDEVICE);
 			memset(lrg_buf_cb, 0, sizeof(struct ql_rcv_buf_cb));
 		} else {
@@ -2912,8 +2912,8 @@ static int ql_alloc_large_buffers(struct ql3_adapter *qdev)
 				return -ENOMEM;
 			}
 
-			pci_unmap_addr_set(lrg_buf_cb, mapaddr, map);
-			pci_unmap_len_set(lrg_buf_cb, maplen,
+			dma_unmap_addr_set(lrg_buf_cb, mapaddr, map);
+			dma_unmap_len_set(lrg_buf_cb, maplen,
 					  qdev->lrg_buffer_len -
 					  QL_HEADER_SPACE);
 			lrg_buf_cb->buf_phy_addr_low =
@@ -3793,13 +3793,13 @@ static void ql_reset_work(struct work_struct *work)
 				       "%s: Freeing lost SKB.\n",
 				       qdev->ndev->name);
 				pci_unmap_single(qdev->pdev,
-					 pci_unmap_addr(&tx_cb->map[0], mapaddr),
-					 pci_unmap_len(&tx_cb->map[0], maplen),
+					 dma_unmap_addr(&tx_cb->map[0], mapaddr),
+					 dma_unmap_len(&tx_cb->map[0], maplen),
 					 PCI_DMA_TODEVICE);
 				for(j=1;j<tx_cb->seg_count;j++) {
 					pci_unmap_page(qdev->pdev,
-					       pci_unmap_addr(&tx_cb->map[j],mapaddr),
-					       pci_unmap_len(&tx_cb->map[j],maplen),
+					       dma_unmap_addr(&tx_cb->map[j],mapaddr),
+					       dma_unmap_len(&tx_cb->map[j],maplen),
 					       PCI_DMA_TODEVICE);
 				}
 				dev_kfree_skb(tx_cb->skb);
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 7113e71..3362a66 100644
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -998,8 +998,8 @@ enum link_state_t {
 struct ql_rcv_buf_cb {
 	struct ql_rcv_buf_cb *next;
 	struct sk_buff *skb;
-	 DECLARE_PCI_UNMAP_ADDR(mapaddr);
-	 DECLARE_PCI_UNMAP_LEN(maplen);
+	DEFINE_DMA_UNMAP_ADDR(mapaddr);
+	DEFINE_DMA_UNMAP_LEN(maplen);
 	__le32 buf_phy_addr_low;
 	__le32 buf_phy_addr_high;
 	int index;
@@ -1029,8 +1029,8 @@ struct oal {
 };
 
 struct map_list {
-	 DECLARE_PCI_UNMAP_ADDR(mapaddr);
-	 DECLARE_PCI_UNMAP_LEN(maplen);
+	DEFINE_DMA_UNMAP_ADDR(mapaddr);
+	DEFINE_DMA_UNMAP_LEN(maplen);
 };
 
 struct ql_tx_buf_cb {
-- 
1.6.5

