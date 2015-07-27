From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next]r8169: Correct values on dma_alloc_coherent
Date: Mon, 27 Jul 2015 13:21:38 +0300
Message-ID: <1437992498-2381-1-git-send-email-corcodel.marian@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34604 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278AbbG0KVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 06:21:50 -0400
Received: by wibud3 with SMTP id ud3so133484350wib.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 03:21:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <asu@192-168-0-3.rdsnet.ro>


   Correct values on dma_alloc_coherent to fit on 256
 wich is size   rx descriptor and tx descriptor provided by the cip.   On my
 chip try to solve running on full duplex wo low speed.   Wo this patch
 running from terminal ethtool -s eth0 autoneg on   from many times to obtain
 full duplex and full speed now(with this   patch) after start network when
 start autoneg for 1 2 times work   on full duplex and full speed(important).

Signed-off-by: Corcodel Marian <asu@192-168-0-3.rdsnet.ro>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3df51fa..fd249a6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6724,8 +6724,8 @@ static int rtl8169_init_ring(struct net_device *dev)
 
 	rtl8169_init_ring_indexes(tp);
 
-	memset(tp->tx_skb, 0x0, NUM_TX_DESC * sizeof(struct ring_info));
-	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC * sizeof(void *));
+	memset(tp->tx_skb, 0x0, NUM_RX_DESC);
+	memset(tp->Rx_databuff, 0x0, NUM_RX_DESC);
 
 	return rtl8169_rx_fill(tp);
 }
@@ -7555,9 +7555,9 @@ static int rtl8169_close(struct net_device *dev)
 
 	free_irq(pdev->irq, dev);
 
-	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
+	dma_free_coherent(&pdev->dev, NUM_RX_DESC, tp->RxDescArray,
 			  tp->RxPhyAddr);
-	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
+	dma_free_coherent(&pdev->dev, NUM_RX_DESC, tp->TxDescArray,
 			  tp->TxPhyAddr);
 	tp->TxDescArray = NULL;
 	tp->RxDescArray = NULL;
@@ -7589,12 +7589,12 @@ static int rtl_open(struct net_device *dev)
 	 * Rx and Tx descriptors needs 256 bytes alignment.
 	 * dma_alloc_coherent provides more.
 	 */
-	tp->TxDescArray = dma_alloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
+	tp->TxDescArray = dma_alloc_coherent(&pdev->dev, NUM_RX_DESC,
 					     &tp->TxPhyAddr, GFP_KERNEL);
 	if (!tp->TxDescArray)
 		goto err_pm_runtime_put;
 
-	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, R8169_RX_RING_BYTES,
+	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, NUM_RX_DESC,
 					     &tp->RxPhyAddr, GFP_KERNEL);
 	if (!tp->RxDescArray)
 		goto err_free_tx_0;
@@ -7644,11 +7644,11 @@ err_release_fw_2:
 	rtl_release_firmware(tp);
 	rtl8169_rx_clear(tp);
 err_free_rx_1:
-	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
+	dma_free_coherent(&pdev->dev, NUM_RX_DESC, tp->RxDescArray,
 			  tp->RxPhyAddr);
 	tp->RxDescArray = NULL;
 err_free_tx_0:
-	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
+	dma_free_coherent(&pdev->dev, NUM_RX_DESC, tp->TxDescArray,
 			  tp->TxPhyAddr);
 	tp->TxDescArray = NULL;
 err_pm_runtime_put:
-- 
2.1.4
