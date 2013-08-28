From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next 1/2] sh_eth: Fix cache invalidation omission of receive buffer
Date: Wed, 28 Aug 2013 09:43:08 +0900
Message-ID: <1377650589-20960-2-git-send-email-horms+renesas@verge.net.au>
References: <1377650589-20960-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Kouei Abe <kouei.abe.cp@renesas.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1377650589-20960-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kouei Abe <kouei.abe.cp@renesas.com>

Signed-off-by: Kouei Abe <kouei.abe.cp@renesas.com>
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/renesas/sh_eth.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index c357076..f386a8f 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1342,6 +1342,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 			mdp->rx_skbuff[entry] = NULL;
 			if (mdp->cd->rpadir)
 				skb_reserve(skb, NET_IP_ALIGN);
+			dma_sync_single_for_cpu(&ndev->dev, rxdesc->addr,
+				mdp->rx_buf_sz,	DMA_FROM_DEVICE);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
 			netif_rx(skb);
-- 
1.8.3.2

