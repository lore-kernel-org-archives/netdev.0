From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next]r8169:Correct size from dma_alloc_coherent Maximum size    register with size argument from dma_alloc_coherent old    variable R8169_RX_RING_BYTES return to much value 17000 instead    of value of rx_buf_sz, another issue is on rtl8169_init_ring func,    Tx buffer and Rx buffer have same number off descriptors NUM_RX_DESC,    not others values.
Date: Mon, 27 Jul 2015 00:19:27 +0300
Message-ID: <1437945567-2495-1-git-send-email-corcodel.marian@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36669 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbbGZVUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 17:20:06 -0400
Received: by wicgb10 with SMTP id gb10so87530957wic.1
        for <netdev@vger.kernel.org>; Sun, 26 Jul 2015 14:20:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3df51fa..561c23a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5200,6 +5200,7 @@ static void rtl_set_rx_tx_desc_registers(struct rtl8169_private *tp,
 	 * register to be written before TxDescAddrLow to work.
 	 * Switching from MMIO to I/O access fixes the issue as well.
 	 */
+	
 	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr) >> 32);
 	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr) & DMA_BIT_MASK(32));
 	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr) >> 32);
@@ -6724,8 +6725,8 @@ static int rtl8169_init_ring(struct net_device *dev)
 
 	rtl8169_init_ring_indexes(tp);
 
-	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
-	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
+	memset(tp->tx_skb, 0x0, NUM_RX_DESC);
+	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC);
 
 	return rtl8169_rx_fill(tp);
 }
@@ -7555,7 +7556,7 @@ static int rtl8169_close(struct net_device *dev)
 
 	free_irq(pdev->irq, dev);
 
-	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
+	dma_free_coherent(&pdev->dev, rx_buf_sz, tp->RxDescArray,
 			  tp->RxPhyAddr);
 	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
 			  tp->TxPhyAddr);
@@ -7594,7 +7595,7 @@ static int rtl_open(struct net_device *dev)
 	if (!tp->TxDescArray)
 		goto err_pm_runtime_put;
 
-	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, R8169_RX_RING_BYTES,
+	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, rx_buf_sz,
 					     &tp->RxPhyAddr, GFP_KERNEL);
 	if (!tp->RxDescArray)
 		goto err_free_tx_0;
@@ -7644,7 +7645,7 @@ err_release_fw_2:
 	rtl_release_firmware(tp);
 	rtl8169_rx_clear(tp);
 err_free_rx_1:
-	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
+	dma_free_coherent(&pdev->dev, rx_buf_sz, tp->RxDescArray,
 			  tp->RxPhyAddr);
 	tp->RxDescArray = NULL;
 err_free_tx_0:
-- 
2.1.4
