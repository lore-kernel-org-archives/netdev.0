From: ganesh.venkatesan@intel.com
Subject: [PATCH 7/12 2.5] e1000 - Use pci_dma_sync_single_[for_device|for_cpu]
Date: Thu, 29 Jul 2004 08:32:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290809160.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_ethtool.c linux-2.5/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.5/drivers/net/e1000/e1000_ethtool.c	2004-07-28 21:50:08.576475768 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_ethtool.c	2004-07-28 21:50:09.395351280 -0700
@@ -1325,15 +1325,15 @@ e1000_run_loopback_test(struct e1000_ada
 
 	for(i = 0; i < 64; i++) {
 		e1000_create_lbtest_frame(txdr->buffer_info[i].skb, 1024);
-		pci_dma_sync_single(pdev, txdr->buffer_info[i].dma,
-				    txdr->buffer_info[i].length,
-				    PCI_DMA_TODEVICE);
+		pci_dma_sync_single_for_device(pdev, txdr->buffer_info[i].dma,
+					    txdr->buffer_info[i].length,
+					    PCI_DMA_TODEVICE);
 	}
 	E1000_WRITE_REG(&adapter->hw, TDT, i);
 
 	msec_delay(200);
 
-	pci_dma_sync_single(pdev, rxdr->buffer_info[0].dma,
+	pci_dma_sync_single_for_cpu(pdev, rxdr->buffer_info[0].dma,
 			    rxdr->buffer_info[0].length, PCI_DMA_FROMDEVICE);
 
 	return e1000_check_lbtest_frame(rxdr->buffer_info[0].skb, 1024);
