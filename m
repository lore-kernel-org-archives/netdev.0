From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH 09/11] net: ll_temac: Move frag loading to frag loop
Date: Thu,  4 Oct 2012 20:14:55 +0200
Message-ID: <1349374497-9540-9-git-send-email-monstr@monstr.eu>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Cc: linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59018 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384Ab2JDSPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 14:15:16 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so510561wey.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 11:15:15 -0700 (PDT)
In-Reply-To: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Load frag value when necessary.

Signed-off-by: Michal Simek <monstr@monstr.eu>
CC: Anirudha Sarangi <anirudh@xilinx.com>
CC: John Linn <John.Linn@xilinx.com>
CC: Grant Likely <grant.likely@secretlab.ca>
CC: Rob Herring <rob.herring@calxeda.com>
CC: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 8bafa15..fec42d9 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -686,7 +686,6 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	skb_frag_t *frag;
 
 	num_frag = skb_shinfo(skb)->nr_frags;
-	frag = &skb_shinfo(skb)->frags[0];
 	start_p = lp->tx_bd_p + sizeof(*lp->tx_bd_v) * lp->tx_bd_tail;
 	cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
 
@@ -715,6 +714,7 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	cur_p->app4 = (unsigned long)skb;
 
 	for (ii = 0; ii < num_frag; ii++) {
+		frag = &skb_shinfo(skb)->frags[ii];
 		lp->tx_bd_tail++;
 		if (lp->tx_bd_tail >= TX_BD_NUM)
 			lp->tx_bd_tail = 0;
@@ -725,7 +725,6 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 					     skb_frag_size(frag), DMA_TO_DEVICE);
 		cur_p->len = skb_frag_size(frag);
 		cur_p->app0 = 0;
-		frag++;
 	}
 	cur_p->app0 |= STS_CTRL_APP0_EOP;
 
-- 
1.7.0.4
