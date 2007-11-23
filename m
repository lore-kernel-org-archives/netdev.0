From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 3/8] ipg: remove IPG_DEV_KFREE_SKB macro
Date: Fri, 23 Nov 2007 10:18:55 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711231018300.18378@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42513 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320AbXKWIS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 03:18:56 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Enberg <penberg@cs.helsinki.fi>

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
Cc: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |   28 ++++++++++++++--------------
 drivers/net/ipg.h |    2 --
 2 files changed, 14 insertions(+), 16 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -776,7 +776,7 @@ static int init_rfdlist(struct net_devic
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-			IPG_DEV_KFREE_SKB(sp->RxBuff[i]);
+			dev_kfree_skb_irq(sp->RxBuff[i]);
 			sp->RxBuff[i] = NULL;
 		}
 
@@ -829,7 +829,7 @@ static void init_tfdlist(struct net_devi
 		txfd->tfc = cpu_to_le64(IPG_TFC_TFDDONE);
 
 		if (sp->TxBuff[i]) {
-			IPG_DEV_KFREE_SKB(sp->TxBuff[i]);
+			dev_kfree_skb_irq(sp->TxBuff[i]);
 			sp->TxBuff[i] = NULL;
 		}
 
@@ -894,7 +894,7 @@ static void ipg_nic_txfree(struct net_de
 				le64_to_cpu(txfd->frag_info) & ~IPG_TFI_FRAGLEN,
 				skb->len, PCI_DMA_TODEVICE);
 
-			IPG_DEV_KFREE_SKB(skb);
+			dev_kfree_skb_irq(skb);
 
 			sp->TxBuff[dirty] = NULL;
 		}
@@ -1121,7 +1121,7 @@ inline void ipg_nic_rx_free_skb(struct n
 		pci_unmap_single(sp->pdev,
 			le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
 			sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-		IPG_DEV_KFREE_SKB(sp->RxBuff[entry]);
+		dev_kfree_skb_irq(sp->RxBuff[entry]);
 		sp->RxBuff[entry] = NULL;
 	}
 }
@@ -1189,7 +1189,7 @@ inline int ipg_nic_rx_check_error(struct
 				le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
-			IPG_DEV_KFREE_SKB(sp->RxBuff[entry]);
+			dev_kfree_skb_irq(sp->RxBuff[entry]);
 			sp->RxBuff[entry] = NULL;
 		}
 		return ErrorPacket;
@@ -1206,7 +1206,7 @@ static void ipg_nic_rx_with_start_and_en
 	int framelen;
 
 	if (jumbo->FoundStart) {
-		IPG_DEV_KFREE_SKB(jumbo->skb);
+		dev_kfree_skb_irq(jumbo->skb);
 		jumbo->FoundStart = 0;
 		jumbo->CurrentSize = 0;
 		jumbo->skb = NULL;
@@ -1251,7 +1251,7 @@ static void ipg_nic_rx_with_start(struct
 		return;
 
 	if (jumbo->FoundStart)
-		IPG_DEV_KFREE_SKB(jumbo->skb);
+		dev_kfree_skb_irq(jumbo->skb);
 
 	pci_unmap_single(pdev, le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
 			 sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
@@ -1290,7 +1290,7 @@ static void ipg_nic_rx_with_end(struct n
 				framelen=IPG_RXFRAG_SIZE;
 			 */
 			if (framelen > IPG_RXSUPPORT_SIZE)
-				IPG_DEV_KFREE_SKB(jumbo->skb);
+				dev_kfree_skb_irq(jumbo->skb);
 			else {
 				memcpy(skb_put(jumbo->skb, endframeLen),
 				       skb->data, endframeLen);
@@ -1310,7 +1310,7 @@ static void ipg_nic_rx_with_end(struct n
 
 		ipg_nic_rx_free_skb(dev);
 	} else {
-		IPG_DEV_KFREE_SKB(jumbo->skb);
+		dev_kfree_skb_irq(jumbo->skb);
 		jumbo->FoundStart = 0;
 		jumbo->CurrentSize = 0;
 		jumbo->skb = NULL;
@@ -1340,7 +1340,7 @@ static void ipg_nic_rx_no_start_no_end(s
 			ipg_nic_rx_free_skb(dev);
 		}
 	} else {
-		IPG_DEV_KFREE_SKB(jumbo->skb);
+		dev_kfree_skb_irq(jumbo->skb);
 		jumbo->FoundStart = 0;
 		jumbo->CurrentSize = 0;
 		jumbo->skb = NULL;
@@ -1481,7 +1481,7 @@ static int ipg_nic_rx(struct net_device 
 					le64_to_cpu(info) & ~IPG_RFI_FRAGLEN,
 					sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
-				IPG_DEV_KFREE_SKB(skb);
+				dev_kfree_skb_irq(skb);
 			}
 		} else {
 
@@ -1574,7 +1574,7 @@ static int ipg_nic_rx(struct net_device 
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-			IPG_DEV_KFREE_SKB(sp->RxBuff[entry]);
+			dev_kfree_skb_irq(sp->RxBuff[entry]);
 		}
 
 		/* Assure RX buffer is not reused by IPG. */
@@ -1747,7 +1747,7 @@ static void ipg_rx_clear(struct ipg_nic_
 		if (sp->RxBuff[i]) {
 			struct ipg_rx *rxfd = sp->rxd + i;
 
-			IPG_DEV_KFREE_SKB(sp->RxBuff[i]);
+			dev_kfree_skb_irq(sp->RxBuff[i]);
 			sp->RxBuff[i] = NULL;
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
@@ -1768,7 +1768,7 @@ static void ipg_tx_clear(struct ipg_nic_
 				le64_to_cpu(txfd->frag_info) & ~IPG_TFI_FRAGLEN,
 				sp->TxBuff[i]->len, PCI_DMA_TODEVICE);
 
-			IPG_DEV_KFREE_SKB(sp->TxBuff[i]);
+			dev_kfree_skb_irq(sp->TxBuff[i]);
 
 			sp->TxBuff[i] = NULL;
 		}
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -27,8 +27,6 @@
 
 #define DrvVer "2.09d"
 
-#define IPG_DEV_KFREE_SKB(skb) dev_kfree_skb_irq(skb)
-
 /*
  *	Constants
  */
