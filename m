From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH net-next v2] ravb: Remove rx buffer ALIGN
Date: Mon,  2 May 2016 00:19:51 +0900
Message-ID: <1462115991-27241-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

Aligning the reception data size is not required.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Tested-by: Simon Horman <horms+renesas@verge.net.au>
---

This patch is based on the master branch of David Miller's next networking
tree.

v2 [Yoshihiro Kaneko]
* As suggested by Sergei Shtylyov
  remove re-formattings which is not related to the subject of this patch.

 drivers/net/ethernet/renesas/ravb_main.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 238b56f..34066e0 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -246,10 +246,9 @@ static void ravb_ring_format(struct net_device *ndev, int q)
 	for (i = 0; i < priv->num_rx_ring[q]; i++) {
 		/* RX descriptor */
 		rx_desc = &priv->rx_ring[q][i];
-		/* The size of the buffer should be on 16-byte boundary. */
-		rx_desc->ds_cc = cpu_to_le16(ALIGN(PKT_BUF_SZ, 16));
+		rx_desc->ds_cc = cpu_to_le16(PKT_BUF_SZ);
 		dma_addr = dma_map_single(ndev->dev.parent, priv->rx_skb[q][i]->data,
-					  ALIGN(PKT_BUF_SZ, 16),
+					  PKT_BUF_SZ,
 					  DMA_FROM_DEVICE);
 		/* We just set the data size to 0 for a failed mapping which
 		 * should prevent DMA from happening...
@@ -558,7 +557,7 @@ static bool ravb_rx(struct net_device *ndev, int *quota, int q)
 			skb = priv->rx_skb[q][entry];
 			priv->rx_skb[q][entry] = NULL;
 			dma_unmap_single(ndev->dev.parent, le32_to_cpu(desc->dptr),
-					 ALIGN(PKT_BUF_SZ, 16),
+					 PKT_BUF_SZ,
 					 DMA_FROM_DEVICE);
 			get_ts &= (q == RAVB_NC) ?
 					RAVB_RXTSTAMP_TYPE_V2_L2_EVENT :
@@ -588,8 +587,7 @@ static bool ravb_rx(struct net_device *ndev, int *quota, int q)
 	for (; priv->cur_rx[q] - priv->dirty_rx[q] > 0; priv->dirty_rx[q]++) {
 		entry = priv->dirty_rx[q] % priv->num_rx_ring[q];
 		desc = &priv->rx_ring[q][entry];
-		/* The size of the buffer should be on 16-byte boundary. */
-		desc->ds_cc = cpu_to_le16(ALIGN(PKT_BUF_SZ, 16));
+		desc->ds_cc = cpu_to_le16(PKT_BUF_SZ);
 
 		if (!priv->rx_skb[q][entry]) {
 			skb = netdev_alloc_skb(ndev,
-- 
1.9.1
