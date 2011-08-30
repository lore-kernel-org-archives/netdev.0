From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 04/14] atl1c: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:20 +0100
Message-ID: <1314695910-22344-4-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:54568 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755Ab1H3JSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 05:18:38 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Cc: Jie Yang <jie.yang@atheros.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index acb4c10..2b9f925 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2180,11 +2180,10 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 
 		buffer_info = atl1c_get_tx_buffer(adapter, use_tpd);
 		buffer_info->length = frag->size;
-		buffer_info->dma =
-			pci_map_page(adapter->pdev, frag->page,
-					frag->page_offset,
-					buffer_info->length,
-					PCI_DMA_TODEVICE);
+		buffer_info->dma = skb_frag_dma_map(&adapter->pdev->dev,
+						    frag, 0,
+						    buffer_info->length,
+						    PCI_DMA_TODEVICE);
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
 		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_PAGE,
 			ATL1C_PCIMAP_TODEVICE);
-- 
1.7.2.5
