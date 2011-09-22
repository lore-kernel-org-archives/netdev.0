From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 05/14] starfire: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:19 +0100
Message-ID: <1316678008-16842-5-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48517 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751345Ab1IVHxi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 03:53:38 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/adaptec/starfire.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index df51fdd..d6b0155 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -1259,7 +1259,10 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 			skb_frag_t *this_frag = &skb_shinfo(skb)->frags[i - 1];
 			status |= this_frag->size;
 			np->tx_info[entry].mapping =
-				pci_map_single(np->pci_dev, page_address(this_frag->page) + this_frag->page_offset, this_frag->size, PCI_DMA_TODEVICE);
+				pci_map_single(np->pci_dev,
+					       skb_frag_address(this_frag),
+					       this_frag->size,
+					       PCI_DMA_TODEVICE);
 		}
 
 		np->tx_ring[entry].addr = cpu_to_dma(np->tx_info[entry].mapping);
-- 
1.7.2.5
