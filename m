From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 03/14] ksz884x: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:46:55 +0100
Message-ID: <1314787626-12273-3-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10632 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab1HaKrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 06:47:11 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/micrel/ksz884x.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 27418d3..710c4ae 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4704,8 +4704,7 @@ static void send_packet(struct sk_buff *skb, struct net_device *dev)
 
 			dma_buf->dma = pci_map_single(
 				hw_priv->pdev,
-				page_address(this_frag->page) +
-				this_frag->page_offset,
+				skb_frag_address(this_frag),
 				dma_buf->len,
 				PCI_DMA_TODEVICE);
 			set_tx_buf(desc, dma_buf->dma);
-- 
1.7.2.5
