From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH 07/11] net: ll_temac: Fix DMA map size bug
Date: Thu,  4 Oct 2012 20:14:53 +0200
Message-ID: <1349374497-9540-7-git-send-email-monstr@monstr.eu>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Cc: linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DMA allocates skb->len instead of headlen
which is used for DMA.
The same fix was applied to the axienet driver.

Signed-off-by: Michal Simek <monstr@monstr.eu>
CC: Anirudha Sarangi <anirudh@xilinx.com>
CC: John Linn <John.Linn@xilinx.com>
CC: Grant Likely <grant.likely@secretlab.ca>
CC: Rob Herring <rob.herring@calxeda.com>
CC: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 482b572..8786d92 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -710,8 +710,8 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	cur_p->app0 |= STS_CTRL_APP0_SOP;
 	cur_p->len = skb_headlen(skb);
-	cur_p->phys = dma_map_single(ndev->dev.parent, skb->data, skb->len,
-				     DMA_TO_DEVICE);
+	cur_p->phys = dma_map_single(ndev->dev.parent, skb->data,
+				skb_headlen(skb), DMA_TO_DEVICE);
 	cur_p->app4 = (unsigned long)skb;
 
 	for (ii = 0; ii < num_frag; ii++) {
-- 
1.7.0.4
