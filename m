From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 07/14] sungem: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:21 +0100
Message-ID: <1316678008-16842-7-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48517 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466Ab1IVHxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 03:53:41 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/sun/sungem.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 11fd299..2bfa171 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -1071,10 +1071,8 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 			u64 this_ctrl;
 
 			len = this_frag->size;
-			mapping = pci_map_page(gp->pdev,
-					       this_frag->page,
-					       this_frag->page_offset,
-					       len, PCI_DMA_TODEVICE);
+			mapping = skb_frag_dma_map(&gp->pdev->dev, this_frag,
+						   0, len, PCI_DMA_TODEVICE);
 			this_ctrl = ctrl;
 			if (frag == skb_shinfo(skb)->nr_frags - 1)
 				this_ctrl |= TXDCTRL_EOF;
-- 
1.7.2.5
