From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH 08/11] net: ll_temac: Do not use fixed mtu size
Date: Thu,  4 Oct 2012 20:14:54 +0200
Message-ID: <1349374497-9540-8-git-send-email-monstr@monstr.eu>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Cc: linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54728 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755108Ab2JDSPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 14:15:15 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so510525wey.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 11:15:14 -0700 (PDT)
In-Reply-To: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use max mtu instead.

Signed-off-by: Michal Simek <monstr@monstr.eu>
CC: Anirudha Sarangi <anirudh@xilinx.com>
CC: John Linn <John.Linn@xilinx.com>
CC: Grant Likely <grant.likely@secretlab.ca>
CC: Rob Herring <rob.herring@calxeda.com>
CC: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 8786d92..8bafa15 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -212,7 +212,7 @@ static void temac_dma_bd_release(struct net_device *ndev)
 			break;
 		else {
 			dma_unmap_single(ndev->dev.parent, lp->rx_bd_v[i].phys,
-					XTE_MAX_JUMBO_FRAME_SIZE, DMA_FROM_DEVICE);
+					ndev->mtu, DMA_FROM_DEVICE);
 			dev_kfree_skb(lp->rx_skb[i]);
 		}
 	}
@@ -274,7 +274,7 @@ static int temac_dma_bd_init(struct net_device *ndev)
 				sizeof(*lp->rx_bd_v) * ((i + 1) % RX_BD_NUM);
 
 		skb = netdev_alloc_skb_ip_align(ndev,
-						XTE_MAX_JUMBO_FRAME_SIZE);
+						ndev->mtu);
 
 		if (skb == 0) {
 			dev_err(&ndev->dev, "alloc_skb error %d\n", i);
@@ -284,9 +284,9 @@ static int temac_dma_bd_init(struct net_device *ndev)
 		/* returns physical address of skb->data */
 		lp->rx_bd_v[i].phys = dma_map_single(ndev->dev.parent,
 						     skb->data,
-						     XTE_MAX_JUMBO_FRAME_SIZE,
+						     ndev->mtu,
 						     DMA_FROM_DEVICE);
-		lp->rx_bd_v[i].len = XTE_MAX_JUMBO_FRAME_SIZE;
+		lp->rx_bd_v[i].len = ndev->mtu;
 		lp->rx_bd_v[i].app0 = STS_CTRL_APP0_IRQONEND;
 	}
 
@@ -787,7 +787,7 @@ static void ll_temac_recv(struct net_device *ndev)
 		ndev->stats.rx_bytes += length;
 
 		new_skb = netdev_alloc_skb_ip_align(ndev,
-						XTE_MAX_JUMBO_FRAME_SIZE);
+						ndev->mtu);
 
 		if (new_skb == 0) {
 			dev_err(&ndev->dev, "no memory for new sk_buff\n");
@@ -797,9 +797,9 @@ static void ll_temac_recv(struct net_device *ndev)
 
 		cur_p->app0 = STS_CTRL_APP0_IRQONEND;
 		cur_p->phys = dma_map_single(ndev->dev.parent, new_skb->data,
-					     XTE_MAX_JUMBO_FRAME_SIZE,
+					     ndev->mtu,
 					     DMA_FROM_DEVICE);
-		cur_p->len = XTE_MAX_JUMBO_FRAME_SIZE;
+		cur_p->len = ndev->mtu;
 		lp->rx_skb[lp->rx_bd_ci] = new_skb;
 
 		lp->rx_bd_ci++;
-- 
1.7.0.4
