From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 07/25] ixgb: move time stamp set before setting dma
	pointer
Date: Tue, 08 Jul 2008 15:51:37 -0700
Message-ID: <20080708225137.6925.95442.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34581 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752314AbYGHWvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:51:38 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

a user pointed out that setting variables out of order with respect
to the checks we make for tx timeout handling could result in a race
where ->dma was set but ->time_stamp was set to the old value.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 0e72dad..4bf6bbc 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1290,12 +1290,12 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 
 		buffer_info->length = size;
 		WARN_ON(buffer_info->dma != 0);
+		buffer_info->time_stamp = jiffies;
 		buffer_info->dma =
 			pci_map_single(adapter->pdev,
 				skb->data + offset,
 				size,
 				PCI_DMA_TODEVICE);
-		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = 0;
 
 		len -= size;
@@ -1322,13 +1322,13 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 				size -= 4;
 
 			buffer_info->length = size;
+			buffer_info->time_stamp = jiffies;
 			buffer_info->dma =
 				pci_map_page(adapter->pdev,
 					frag->page,
 					frag->page_offset + offset,
 					size,
 					PCI_DMA_TODEVICE);
-			buffer_info->time_stamp = jiffies;
 			buffer_info->next_to_watch = 0;
 
 			len -= size;

