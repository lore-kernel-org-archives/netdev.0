From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 01/14] s2io: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:15 +0100
Message-ID: <1316678008-16842-1-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48517 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962Ab1IVHxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 03:53:32 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jon Mason <jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/neterion/s2io.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 840cbb2..ef5b825 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -4190,10 +4190,10 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!frag->size)
 			continue;
 		txdp++;
-		txdp->Buffer_Pointer = (u64)pci_map_page(sp->pdev, frag->page,
-							 frag->page_offset,
-							 frag->size,
-							 PCI_DMA_TODEVICE);
+		txdp->Buffer_Pointer = (u64)skb_frag_dma_map(&sp->pdev->dev,
+							     frag, 0,
+							     frag->size,
+							     PCI_DMA_TODEVICE);
 		txdp->Control_1 = TXD_BUFFER0_SIZE(frag->size);
 		if (offload_type == SKB_GSO_UDP)
 			txdp->Control_1 |= TXD_UFO_EN;
-- 
1.7.2.5
