From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 05/14] atl1e: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:21 +0100
Message-ID: <1314695910-22344-5-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34590 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311Ab1H3JSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 05:18:39 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Cc: Jie Yang <jie.yang@atheros.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 1b5dc79..7e27eb3 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1765,12 +1765,11 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
 				MAX_TX_BUF_LEN : buf_len;
 			buf_len -= tx_buffer->length;
 
-			tx_buffer->dma =
-				pci_map_page(adapter->pdev, frag->page,
-						frag->page_offset +
-						(i * MAX_TX_BUF_LEN),
-						tx_buffer->length,
-						PCI_DMA_TODEVICE);
+			tx_buffer->dma = skb_frag_dma_map(&adapter->pdev->dev,
+							  frag,
+							  (i * MAX_TX_BUF_LEN),
+							  tx_buffer->length,
+							  PCI_DMA_TODEVICE);
 			ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_PAGE);
 			use_tpd->buffer_addr = cpu_to_le64(tx_buffer->dma);
 			use_tpd->word2 = (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |
-- 
1.7.2.5
