From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 09/14] tehuti: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:23 +0100
Message-ID: <1316678008-16842-9-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Alexander Indenbaum <baum@tehutinetworks.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48517 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751584Ab1IVHxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 03:53:43 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Alexander Indenbaum <baum@tehutinetworks.net>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/tehuti/tehuti.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index bc65aa8..371ab7a 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1497,9 +1497,9 @@ bdx_tx_map_skb(struct bdx_priv *priv, struct sk_buff *skb,
 
 		frag = &skb_shinfo(skb)->frags[i];
 		db->wptr->len = frag->size;
-		db->wptr->addr.dma =
-		    pci_map_page(priv->pdev, frag->page, frag->page_offset,
-				 frag->size, PCI_DMA_TODEVICE);
+		db->wptr->addr.dma = skb_frag_dma_map(&priv->pdev->dev, frag,
+						      0, frag->size,
+						      PCI_DMA_TODEVICE);
 
 		pbl++;
 		pbl->len = CPU_CHIP_SWAP32(db->wptr->len);
-- 
1.7.2.5
