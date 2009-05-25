From: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Subject: [PATCH 1/5] net: sh_eth: fix cache coherency issue
Date: Mon, 25 May 2009 18:52:35 +0900
Message-ID: <4A1A6A63.8040608@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>,
	Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the problem that may not work receive process by cache coherency issue.

Signed-off-by: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
---
 drivers/net/sh_eth.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 3ab28bb..a742297 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -250,6 +250,8 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		mdp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
+		dma_map_single(&ndev->dev, skb->tail, mdp->rx_buf_sz,
+				DMA_FROM_DEVICE);
 		skb->dev = ndev; /* Mark as being used by this device. */
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
 		reserve = SH7763_SKB_ALIGN
@@ -559,6 +561,8 @@ static int sh_eth_rx(struct net_device *ndev)
 			mdp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
+			dma_map_single(&ndev->dev, skb->tail, mdp->rx_buf_sz,
+					DMA_FROM_DEVICE);
 			skb->dev = ndev;
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
 			reserve = SH7763_SKB_ALIGN
-- 
1.5.5

