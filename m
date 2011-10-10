From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 8/9] ll_temac: convert to SKB paged frag API.
Date: Mon, 10 Oct 2011 12:11:40 +0100
Message-ID: <1318245101-16890-8-git-send-email-ian.campbell@citrix.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:47504 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753739Ab1JJLLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 07:11:54 -0400
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 570776e..66e3c36 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -715,8 +715,7 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 		cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
 		cur_p->phys = dma_map_single(ndev->dev.parent,
-					     (void *)page_address(frag->page) +
-					          frag->page_offset,
+					     skb_frag_address(frag),
 					     frag->size, DMA_TO_DEVICE);
 		cur_p->len = frag->size;
 		cur_p->app0 = 0;
-- 
1.7.2.5
