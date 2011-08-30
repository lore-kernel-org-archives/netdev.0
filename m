From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 01/14] 3c59x: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:17 +0100
Message-ID: <1314695910-22344-1-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34590 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531Ab1H3JSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 05:18:34 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/3com/3c59x.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 6e1f595..9ca45dc 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2179,9 +2179,10 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			vp->tx_ring[entry].frag[i+1].addr =
-					cpu_to_le32(pci_map_single(VORTEX_PCI(vp),
-											   (void*)page_address(frag->page) + frag->page_offset,
-											   frag->size, PCI_DMA_TODEVICE));
+					cpu_to_le32(pci_map_single(
+						VORTEX_PCI(vp),
+						(void *)skb_frag_address(frag),
+						frag->size, PCI_DMA_TODEVICE));
 
 			if (i == skb_shinfo(skb)->nr_frags-1)
 					vp->tx_ring[entry].frag[i+1].length = cpu_to_le32(frag->size|LAST_FRAG);
-- 
1.7.2.5
