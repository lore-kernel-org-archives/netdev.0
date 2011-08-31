From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 09/14] pasemi: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:47:01 +0100
Message-ID: <1314787626-12273-9-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Olof Johansson <olof@lixom.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10632 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754360Ab1HaKrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 06:47:18 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Olof Johansson <olof@lixom.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/pasemi/pasemi_mac.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index fad620d..5322095 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1505,9 +1505,8 @@ static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
 	for (i = 0; i < nfrags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		map[i+1] = pci_map_page(mac->dma_pdev, frag->page,
-					frag->page_offset, frag->size,
-					PCI_DMA_TODEVICE);
+		map[i + 1] = skb_frag_dma_map(&mac->dma_pdev->dev, frag, 0,
+					      frag->size, PCI_DMA_TODEVICE);
 		map_size[i+1] = frag->size;
 		if (pci_dma_mapping_error(mac->dma_pdev, map[i+1])) {
 			nfrags = i;
-- 
1.7.2.5
