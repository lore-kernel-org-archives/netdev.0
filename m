From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] ixgbevf: Streamline the rx buffer allocation
Date: Thu, 15 Nov 2012 06:39:40 -0800
Message-ID: <1352990387-3872-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10434 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993466Ab2KOOjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 09:39:53 -0500
In-Reply-To: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Moves allocation of local variable to section where it is needed and
removes unnecessary if statement.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 9d88153..b46dff8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -341,15 +341,16 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbevf_rx_buffer *bi;
-	struct sk_buff *skb;
 	unsigned int i = rx_ring->next_to_use;
 
 	bi = &rx_ring->rx_buffer_info[i];
 
 	while (cleaned_count--) {
 		rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
-		skb = bi->skb;
-		if (!skb) {
+
+		if (!bi->skb) {
+			struct sk_buff *skb;
+
 			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
 							rx_ring->rx_buf_len);
 			if (!skb) {
@@ -357,8 +358,7 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 				goto no_buffers;
 			}
 			bi->skb = skb;
-		}
-		if (!bi->dma) {
+
 			bi->dma = dma_map_single(&pdev->dev, skb->data,
 						 rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
-- 
1.7.11.7
