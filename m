From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 46/75] s2io: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:18 +0100
Message-ID: <1313760467-8598-46-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37564 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755160Ab1HSN3W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:29:22 -0400
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jon Mason <jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/s2io.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 277d48b..8437a05 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
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

