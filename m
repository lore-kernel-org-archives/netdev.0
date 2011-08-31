From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 08/14] ns83820: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:47:00 +0100
Message-ID: <1314787626-12273-8-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55267 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754337Ab1HaKrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 06:47:17 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/natsemi/ns83820.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 1a1e20e..e0895e4 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1160,9 +1160,8 @@ again:
 		if (!nr_frags)
 			break;
 
-		buf = pci_map_page(dev->pci_dev, frag->page,
-				   frag->page_offset,
-				   frag->size, PCI_DMA_TODEVICE);
+		buf = skb_frag_dma_map(&dev->pci_dev->dev, frag, 0,
+				       frag->size, PCI_DMA_TODEVICE);
 		dprintk("frag: buf=%08Lx  page=%08lx offset=%08lx\n",
 			(long long)buf, (long) page_to_pfn(frag->page),
 			frag->page_offset);
-- 
1.7.2.5
