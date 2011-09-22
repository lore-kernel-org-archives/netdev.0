From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 11/14] typhoon: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:25 +0100
Message-ID: <1316678008-16842-11-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	David Dillow <dave@thedillows.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48517 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684Ab1IVHxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 03:53:45 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: David Dillow <dave@thedillows.org>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/3com/typhoon.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index f1dc9acf..607c09e 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -819,8 +819,7 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 			typhoon_inc_tx_index(&txRing->lastWrite, 1);
 
 			len = frag->size;
-			frag_addr = (void *) page_address(frag->page) +
-						frag->page_offset;
+			frag_addr = skb_frag_address(frag);
 			skb_dma = pci_map_single(tp->tx_pdev, frag_addr, len,
 					 PCI_DMA_TODEVICE);
 			txd->flags = TYPHOON_FRAG_DESC | TYPHOON_DESC_VALID;
-- 
1.7.2.5
