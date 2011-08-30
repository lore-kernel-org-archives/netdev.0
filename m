From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 06/14] atlx: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:22 +0100
Message-ID: <1314695910-22344-6-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:1303 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598Ab1H3JSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 05:18:41 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Cc: Jie Yang <jie.yang@atheros.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/atheros/atlx/atl1.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index c34e8239..edf826a 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2283,9 +2283,8 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 			buffer_info->length = (buf_len > ATL1_MAX_TX_BUF_LEN) ?
 				ATL1_MAX_TX_BUF_LEN : buf_len;
 			buf_len -= buffer_info->length;
-			buffer_info->dma = pci_map_page(adapter->pdev,
-				frag->page,
-				frag->page_offset + (i * ATL1_MAX_TX_BUF_LEN),
+			buffer_info->dma = skb_frag_dma_map(&adapter->pdev->dev,
+				frag, i * ATL1_MAX_TX_BUF_LEN,
 				buffer_info->length, PCI_DMA_TODEVICE);
 
 			if (++next_to_use == tpd_ring->count)
-- 
1.7.2.5
