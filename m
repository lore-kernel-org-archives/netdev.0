From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 14/14] r8169: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:47:06 +0100
Message-ID: <1314787626-12273-14-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55267 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754316Ab1HaKr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 06:47:28 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/realtek/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 1cf8c3c..835bbb5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5027,7 +5027,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 
 		txd = tp->TxDescArray + entry;
 		len = frag->size;
-		addr = ((void *) page_address(frag->page)) + frag->page_offset;
+		addr = skb_frag_address(frag);
 		mapping = dma_map_single(d, addr, len, DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(d, mapping))) {
 			if (net_ratelimit())
-- 
1.7.2.5
