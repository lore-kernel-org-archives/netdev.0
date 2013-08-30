From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next v2 1/2] sh_eth: Fix cache invalidation omission of receive buffer
Date: Fri, 30 Aug 2013 12:41:07 +0900
Message-ID: <1377834068-6978-2-git-send-email-horms+renesas@verge.net.au>
References: <1377834068-6978-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Kouei Abe <kouei.abe.cp@renesas.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48941 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435Ab3H3DjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:39:00 -0400
In-Reply-To: <1377834068-6978-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kouei Abe <kouei.abe.cp@renesas.com>

Signed-off-by: Kouei Abe <kouei.abe.cp@renesas.com>
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v2 [Simon Horman]
* Correct indentation

 drivers/net/ethernet/renesas/sh_eth.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 4b47300..3c0a24a 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1342,6 +1342,9 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 			mdp->rx_skbuff[entry] = NULL;
 			if (mdp->cd->rpadir)
 				skb_reserve(skb, NET_IP_ALIGN);
+			dma_sync_single_for_cpu(&ndev->dev, rxdesc->addr,
+						mdp->rx_buf_sz,
+						DMA_FROM_DEVICE);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
 			netif_rx(skb);
-- 
1.8.4.rc4
