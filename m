From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2] net: ll_temac: Fix DMA map size bug
Date: Tue, 12 May 2015 08:06:15 +0200
Message-ID: <66b8efd7a63674220d55a03d0220897bd8b8712b.1431410769.git.michal.simek@xilinx.com>
Cc: =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	monstr@monstr.eu, Fabian Frederick <fabf@skynet.be>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Markus Elfring <elfring@users.sourceforge.net>,
	Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DMA allocates skb->len instead of headlen
which is used for DMA.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

Changes in v2:
- Align the later argument with the right side of the parenthesis
  Reported-by: Julia Lawall <julia.lawall@lip6.fr>

 drivers/net/ethernet/xilinx/ll_temac_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index ca640d04fd93..3b99a4df71f8 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -705,8 +705,8 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	cur_p->app0 |= STS_CTRL_APP0_SOP;
 	cur_p->len = skb_headlen(skb);
-	cur_p->phys = dma_map_single(ndev->dev.parent, skb->data, skb->len,
-				     DMA_TO_DEVICE);
+	cur_p->phys = dma_map_single(ndev->dev.parent, skb->data,
+				     skb_headlen(skb), DMA_TO_DEVICE);
 	cur_p->app4 = (unsigned long)skb;
 
 	for (ii = 0; ii < num_frag; ii++) {
-- 
2.3.5
