From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] net: atheros: atl1: use offset_in_page() macro
Date: Sat, 22 Apr 2017 09:21:10 +0800
Message-ID: <c8746e014d4f7121ab4602548e199f8e8f2fc083.1492758007.git.geliangtang@gmail.com>
References: <4dbc77ccaaed98b183cf4dba58a4fa325fd65048.1492758503.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>,
        Chris Snook <chris.snook@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4dbc77ccaaed98b183cf4dba58a4fa325fd65048.1492758503.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use offset_in_page() macro instead of open-coding.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 022772e..83d2db2 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -1886,7 +1886,7 @@ static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
 		buffer_info->skb = skb;
 		buffer_info->length = (u16) adapter->rx_buffer_len;
 		page = virt_to_page(skb->data);
-		offset = (unsigned long)skb->data & ~PAGE_MASK;
+		offset = offset_in_page(skb->data);
 		buffer_info->dma = pci_map_page(pdev, page, offset,
 						adapter->rx_buffer_len,
 						PCI_DMA_FROMDEVICE);
@@ -2230,7 +2230,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		buffer_info->length = hdr_len;
 		page = virt_to_page(skb->data);
-		offset = (unsigned long)skb->data & ~PAGE_MASK;
+		offset = offset_in_page(skb->data);
 		buffer_info->dma = pci_map_page(adapter->pdev, page,
 						offset, hdr_len,
 						PCI_DMA_TODEVICE);
@@ -2254,9 +2254,8 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 				data_len -= buffer_info->length;
 				page = virt_to_page(skb->data +
 					(hdr_len + i * ATL1_MAX_TX_BUF_LEN));
-				offset = (unsigned long)(skb->data +
-					(hdr_len + i * ATL1_MAX_TX_BUF_LEN)) &
-					~PAGE_MASK;
+				offset = offset_in_page(skb->data +
+					(hdr_len + i * ATL1_MAX_TX_BUF_LEN));
 				buffer_info->dma = pci_map_page(adapter->pdev,
 					page, offset, buffer_info->length,
 					PCI_DMA_TODEVICE);
@@ -2268,7 +2267,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 		/* not TSO */
 		buffer_info->length = buf_len;
 		page = virt_to_page(skb->data);
-		offset = (unsigned long)skb->data & ~PAGE_MASK;
+		offset = offset_in_page(skb->data);
 		buffer_info->dma = pci_map_page(adapter->pdev, page,
 			offset, buf_len, PCI_DMA_TODEVICE);
 		if (++next_to_use == tpd_ring->count)
-- 
2.9.3
