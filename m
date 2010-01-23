From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igb/igbvf: cleanup exception handling in tx_map_adv
Date: Sat, 23 Jan 2010 01:32:51 -0800
Message-ID: <20100123093225.11466.42278.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:52031
	"EHLO qmta15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752570Ab0AWJdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:33:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

After removing the skb_dma_map/unmap calls the exception handling in
igb_tx_map_adv is not correct.  The issue is that the count value was not
being correctly handled so as a result we were not rewinding the ring as
back as we should have been.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    2 +-
 drivers/net/igbvf/netdev.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 933c64f..2ca1734 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3584,6 +3584,7 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
 		struct skb_frag_struct *frag;
 
+		count++;
 		i++;
 		if (i == tx_ring->count)
 			i = 0;
@@ -3605,7 +3606,6 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 		if (pci_dma_mapping_error(pdev, buffer_info->dma))
 			goto dma_error;
 
-		count++;
 	}
 
 	tx_ring->buffer_info[i].skb = skb;
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 10e038a..43c8375 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2126,6 +2126,7 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
 		struct skb_frag_struct *frag;
 
+		count++;
 		i++;
 		if (i == tx_ring->count)
 			i = 0;
@@ -2146,7 +2147,6 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
 						PCI_DMA_TODEVICE);
 		if (pci_dma_mapping_error(pdev, buffer_info->dma))
 			goto dma_error;
-		count++;
 	}
 
 	tx_ring->buffer_info[i].skb = skb;

