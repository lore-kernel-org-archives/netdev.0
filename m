From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 13/13] igbvf: resolve "frees DMA memory with
	different size" warnings
Date: Thu, 23 Jul 2009 21:11:01 -0700
Message-ID: <20090724041100.30709.78568.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:42219
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751524AbZGXELT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:11:19 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change resolves some warnings seen with DMA debugging enabled in which
we were mapping skb->data with size + NET_IP_ALIGN and unmapping it with
just size.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/netdev.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 2bc9d63..926c31b 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -149,7 +149,6 @@ static void igbvf_alloc_rx_buffers(struct igbvf_ring *rx_ring,
 		bufsz = adapter->rx_ps_hdr_size;
 	else
 		bufsz = adapter->rx_buffer_len;
-	bufsz += NET_IP_ALIGN;
 
 	while (cleaned_count--) {
 		rx_desc = IGBVF_RX_DESC_ADV(*rx_ring, i);
@@ -173,7 +172,7 @@ static void igbvf_alloc_rx_buffers(struct igbvf_ring *rx_ring,
 		}
 
 		if (!buffer_info->skb) {
-			skb = netdev_alloc_skb(netdev, bufsz);
+			skb = netdev_alloc_skb(netdev, bufsz + NET_IP_ALIGN);
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
 				goto no_buffers;
@@ -286,7 +285,7 @@ static bool igbvf_clean_rx_irq(struct igbvf_adapter *adapter,
 
 		if (!skb_shinfo(skb)->nr_frags) {
 			pci_unmap_single(pdev, buffer_info->dma,
-			                 adapter->rx_ps_hdr_size + NET_IP_ALIGN,
+			                 adapter->rx_ps_hdr_size,
 			                 PCI_DMA_FROMDEVICE);
 			skb_put(skb, hlen);
 		}

