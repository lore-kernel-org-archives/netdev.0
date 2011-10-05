From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Wed, 5 Oct 2011 11:28:45 +0100
Message-ID: <1317810532-24984-1-git-send-email-ian.campbell@citrix.com>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34524 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934263Ab1JEK24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 06:28:56 -0400
In-Reply-To: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jon Mason <jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index ef1ba204..7420e19 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -923,9 +923,9 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!frag->size)
 			continue;
 
-		dma_pointer = (u64) pci_map_page(fifo->pdev, frag->page,
-				frag->page_offset, frag->size,
-				PCI_DMA_TODEVICE);
+		dma_pointer = (u64)skb_frag_dma_map(&fifo->pdev->dev, frag,
+						    0, frag->size,
+						    PCI_DMA_TODEVICE);
 
 		if (unlikely(pci_dma_mapping_error(fifo->pdev, dma_pointer)))
 			goto _exit2;
-- 
1.7.2.5
