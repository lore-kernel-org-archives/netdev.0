From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 03/14] acenic: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:19 +0100
Message-ID: <1314695910-22344-3-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jes Sorensen <jes@trained-monkey.org>, linux-acenic@sunsite.dk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34590 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598Ab1H3JSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 05:18:36 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jes Sorensen <jes@trained-monkey.org>
Cc: linux-acenic@sunsite.dk
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/alteon/acenic.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index 1d6f2db..8794cf8 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -2485,9 +2485,9 @@ restart:
 			info = ap->skb->tx_skbuff + idx;
 			desc = ap->tx_ring + idx;
 
-			mapping = pci_map_page(ap->pdev, frag->page,
-					       frag->page_offset, frag->size,
-					       PCI_DMA_TODEVICE);
+			mapping = skb_frag_dma_map(&ap->pdev->dev, frag, 0,
+						   frag->size,
+						   PCI_DMA_TODEVICE);
 
 			flagsize = (frag->size << 16);
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
-- 
1.7.2.5
