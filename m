From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 8/8] chelsio: convert to SKB paged frag API.
Date: Wed, 5 Oct 2011 11:28:52 +0100
Message-ID: <1317810532-24984-8-git-send-email-ian.campbell@citrix.com>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27833 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934355Ab1JEK3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 06:29:06 -0400
In-Reply-To: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Divy Le Ray <divy@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/chelsio/cxgb/sge.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index e9a03ff..7cde425 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1277,9 +1277,8 @@ static inline void write_tx_descs(struct adapter *adapter, struct sk_buff *skb,
 			ce = q->centries;
 		}
 
-		mapping = pci_map_page(adapter->pdev, frag->page,
-				       frag->page_offset, frag->size,
-				       PCI_DMA_TODEVICE);
+		mapping = skb_frag_dma_map(&adapter->pdev->dev, frag, 0,
+					   frag->size, PCI_DMA_TODEVICE);
 		desc_mapping = mapping;
 		desc_len = frag->size;
 
-- 
1.7.2.5
