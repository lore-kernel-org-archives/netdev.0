From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 12/14] qlcnic: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:47:04 +0100
Message-ID: <1314787626-12273-12-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55267 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754587Ab1HaKrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 06:47:23 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Cc: Sony Chacko <sony.chacko@qlogic.com>
Cc: linux-driver@qlogic.com
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 690c93f..501e16b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2135,8 +2135,8 @@ qlcnic_map_tx_skb(struct pci_dev *pdev,
 		frag = &skb_shinfo(skb)->frags[i];
 		nf = &pbuf->frag_array[i+1];
 
-		map = pci_map_page(pdev, frag->page, frag->page_offset,
-				frag->size, PCI_DMA_TODEVICE);
+		map = skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
+				       PCI_DMA_TODEVICE);
 		if (pci_dma_mapping_error(pdev, map))
 			goto unwind;
 
-- 
1.7.2.5
