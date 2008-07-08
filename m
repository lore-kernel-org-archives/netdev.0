From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 22/25] ixgb: audit use of dev_kfree_skb_any
Date: Tue, 08 Jul 2008 15:52:53 -0700
Message-ID: <20080708225253.6925.88858.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48202 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754957AbYGHWwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:54 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

calls to kfree_skb_any are only required when calling kfree
from interrupt context.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 05b2677..3e857c0 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -903,8 +903,10 @@ ixgb_unmap_and_free_tx_resource(struct ixgb_adapter *adapter,
 		pci_unmap_page(pdev, buffer_info->dma, buffer_info->length,
 		               PCI_DMA_TODEVICE);
 
+	/* okay to call kfree_skb here instead of kfree_skb_any because
+	 * this is never called in interrupt context */
 	if (buffer_info->skb)
-		dev_kfree_skb_any(buffer_info->skb);
+		dev_kfree_skb(buffer_info->skb);
 
 	buffer_info->skb = NULL;
 	buffer_info->dma = 0;
@@ -1447,7 +1449,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (skb->len <= 0) {
-		dev_kfree_skb_any(skb);
+		dev_kfree_skb(skb);
 		return 0;
 	}
 
@@ -1464,7 +1466,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	tso = ixgb_tso(adapter, skb);
 	if (tso < 0) {
-		dev_kfree_skb_any(skb);
+		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 

