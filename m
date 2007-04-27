From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] ixgb: ROUND_UP macro cleanup in drivers/net/ixgb
Date: Fri, 27 Apr 2007 13:55:31 -0700
Message-ID: <20070427205531.21115.33056.stgit@localhost.localdomain>
References: <20070427205529.21115.55629.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37903 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757237AbXD0Uzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 16:55:33 -0400
In-Reply-To: <20070427205529.21115.55629.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Milind Arun Choudhary <milindchoudhary@gmail.com>

IXGB_ROUNDUP macro cleanup ,use ALIGN

Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h         |    3 ---
 drivers/net/ixgb/ixgb_ethtool.c |    4 ++--
 drivers/net/ixgb/ixgb_main.c    |    4 ++--
 drivers/net/ixgb/ixgb_param.c   |    4 ++--
 4 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index cf30a10..c8e9086 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -111,9 +111,6 @@ struct ixgb_adapter;
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IXGB_RX_BUFFER_WRITE	8	/* Must be power of 2 */
 
-/* only works for sizes that are powers of 2 */
-#define IXGB_ROUNDUP(i, size) ((i) = (((i) + (size) - 1) & ~((size) - 1)))
-
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgb_buffer {
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index d6628bd..afde848 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -577,11 +577,11 @@ ixgb_set_ringparam(struct net_device *netdev,
 
 	rxdr->count = max(ring->rx_pending,(uint32_t)MIN_RXD);
 	rxdr->count = min(rxdr->count,(uint32_t)MAX_RXD);
-	IXGB_ROUNDUP(rxdr->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE); 
+	rxdr->count = ALIGN(rxdr->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
 
 	txdr->count = max(ring->tx_pending,(uint32_t)MIN_TXD);
 	txdr->count = min(txdr->count,(uint32_t)MAX_TXD);
-	IXGB_ROUNDUP(txdr->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE); 
+	txdr->count = ALIGN(txdr->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 
 	if(netif_running(adapter->netdev)) {
 		/* Try to get new resources before deleting old */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index dfde80e..6d2b059 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -685,7 +685,7 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	/* round up to nearest 4K */
 
 	txdr->size = txdr->count * sizeof(struct ixgb_tx_desc);
-	IXGB_ROUNDUP(txdr->size, 4096);
+	txdr->size = ALIGN(txdr->size, 4096);
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
@@ -774,7 +774,7 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 	/* Round up to nearest 4K */
 
 	rxdr->size = rxdr->count * sizeof(struct ixgb_rx_desc);
-	IXGB_ROUNDUP(rxdr->size, 4096);
+	rxdr->size = ALIGN(rxdr->size, 4096);
 
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index b27442a..ee8cc67 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -284,7 +284,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		} else {
 			tx_ring->count = opt.def;
 		}
-		IXGB_ROUNDUP(tx_ring->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
+		tx_ring->count = ALIGN(tx_ring->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 	}
 	{ /* Receive Descriptor Count */
 		struct ixgb_option opt = {
@@ -303,7 +303,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		} else {
 			rx_ring->count = opt.def;
 		}
-		IXGB_ROUNDUP(rx_ring->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
+		rx_ring->count = ALIGN(rx_ring->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
 	}
 	{ /* Receive Checksum Offload Enable */
 		struct ixgb_option opt = {
