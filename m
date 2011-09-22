From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 10/14] tsi108: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:24 +0100
Message-ID: <1316678008-16842-10-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:56495 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659Ab1IVHxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 03:53:44 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/tundra/tsi108_eth.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 480a4ba..a03996c 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -711,9 +711,10 @@ static int tsi108_send_packet(struct sk_buff * skb, struct net_device *dev)
 		} else {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i - 1];
 
-			data->txring[tx].buf0 =
-			    dma_map_page(NULL, frag->page, frag->page_offset,
-					    frag->size, DMA_TO_DEVICE);
+			data->txring[tx].buf0 = skb_frag_dma_map(NULL, frag,
+								 0,
+								 frag->size,
+								 DMA_TO_DEVICE);
 			data->txring[tx].len = frag->size;
 		}
 
-- 
1.7.2.5
