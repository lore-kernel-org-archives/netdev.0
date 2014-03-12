From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 7/9] xilinx: Convert uses of __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:22:36 -0700
Message-ID: <2722ce785ea17ccd8bdbb20f0accd89232aa2b2a.1394644825.git.joe@perches.com>
References: <cover.1394644825.git.joe@perches.com>
Cc: Michal Simek <michal.simek@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1394644825.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c       | 4 ++--
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index a434750..fa193c4 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -771,8 +771,8 @@ static void ll_temac_recv(struct net_device *ndev)
 
 		/* if we're doing rx csum offload, set it up */
 		if (((lp->temac_features & TEMAC_FEATURE_RX_CSUM) != 0) &&
-			(skb->protocol == __constant_htons(ETH_P_IP)) &&
-			(skb->len > 64)) {
+		    (skb->protocol == htons(ETH_P_IP)) &&
+		    (skb->len > 64)) {
 
 			skb->csum = cur_p->app3 & 0xFFFF;
 			skb->ip_summed = CHECKSUM_COMPLETE;
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 4bfdf8c..7b0a735 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -756,7 +756,7 @@ static void axienet_recv(struct net_device *ndev)
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 			}
 		} else if ((lp->features & XAE_FEATURE_PARTIAL_RX_CSUM) != 0 &&
-			   skb->protocol == __constant_htons(ETH_P_IP) &&
+			   skb->protocol == htons(ETH_P_IP) &&
 			   skb->len > 64) {
 			skb->csum = be32_to_cpu(cur_p->app3 & 0xFFFF);
 			skb->ip_summed = CHECKSUM_COMPLETE;
-- 
1.8.1.2.459.gbcd45b4.dirty
