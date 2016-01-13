From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 1/2] 3c59x: balance page maps and unmaps
Date: Wed, 13 Jan 2016 12:43:53 -0500
Message-ID: <1452707034-16379-2-git-send-email-nhorman@tuxdriver.com>
References: <1452707034-16379-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33266 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754211AbcAMRoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 12:44:25 -0500
In-Reply-To: <1452707034-16379-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

debug kernel noticed a screw up in 3c59x.  skbs being mapped as page were being
unmapped as singles.  Easy fix.  Tested by myself

Signed-off-by: Neil Horman <nhorman@tuxdriver.com
CC: "David S. Miller" <davem@davemloft.net>
CC: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
---
 drivers/net/ethernet/3com/3c59x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 2839af0..eec4a3a 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2460,7 +2460,7 @@ boomerang_interrupt(int irq, void *dev_id)
 #if DO_ZEROCOPY
 					int i;
 					for (i=0; i<=skb_shinfo(skb)->nr_frags; i++)
-							pci_unmap_single(VORTEX_PCI(vp),
+							pci_unmap_page(VORTEX_PCI(vp),
 											 le32_to_cpu(vp->tx_ring[entry].frag[i].addr),
 											 le32_to_cpu(vp->tx_ring[entry].frag[i].length)&0xFFF,
 											 PCI_DMA_TODEVICE);
-- 
2.5.0
