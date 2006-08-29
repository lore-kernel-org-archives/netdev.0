From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 23/26] ixgb: Add buffer_info and test like e1000 has.
Date: Tue, 29 Aug 2006 09:45:05 -0700
Message-ID: <20060829164505.6872.7048.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:58890 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965099AbWH2Qgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:52 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 960b44b..a5da48a 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1174,6 +1174,7 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 	int err;
 
 	if (likely(skb_is_gso(skb))) {
+		struct ixgb_buffer *buffer_info;
 		if (skb_header_cloned(skb)) {
 			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 			if (err)
@@ -1196,6 +1197,8 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 
 		i = adapter->tx_ring.next_to_use;
 		context_desc = IXGB_CONTEXT_DESC(adapter->tx_ring, i);
+		buffer_info = &adapter->tx_ring.buffer_info[i];
+		WARN_ON(buffer_info->dma != 0);
 
 		context_desc->ipcss = ipcss;
 		context_desc->ipcso = ipcso;
@@ -1233,11 +1236,14 @@ ixgb_tx_csum(struct ixgb_adapter *adapte
 	uint8_t css, cso;
 
 	if(likely(skb->ip_summed == CHECKSUM_HW)) {
+		struct ixgb_buffer *buffer_info;
 		css = skb->h.raw - skb->data;
 		cso = (skb->h.raw + skb->csum) - skb->data;
 
 		i = adapter->tx_ring.next_to_use;
 		context_desc = IXGB_CONTEXT_DESC(adapter->tx_ring, i);
+		buffer_info = &adapter->tx_ring.buffer_info[i];
+		WARN_ON(buffer_info->dma != 0);
 
 		context_desc->tucss = css;
 		context_desc->tucso = cso;
@@ -1283,6 +1289,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, IXGB_MAX_DATA_PER_TXD);
 		buffer_info->length = size;
+		WARN_ON(buffer_info->dma != 0);
 		buffer_info->dma =
 			pci_map_single(adapter->pdev,
 				skb->data + offset,



---
Auke Kok <auke-jan.h.kok@intel.com>
