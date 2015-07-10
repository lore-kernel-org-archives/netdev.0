From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] ravb: kill useless initializers
Date: Fri, 10 Jul 2015 21:10:10 +0300
Message-ID: <3087282.SVZhuJYtXK@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some of the local variable intializers in the driver turned out to be pointless,
kill them.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the Dave Miller's 'net-next.git' repo.

Changes in version 2:
- fixed typo in the subject.

 drivers/net/ethernet/renesas/ravb_main.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net-next/drivers/net/ethernet/renesas/ravb_main.c
@@ -223,9 +223,9 @@ static void ravb_ring_free(struct net_de
 static void ravb_ring_format(struct net_device *ndev, int q)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
-	struct ravb_ex_rx_desc *rx_desc = NULL;
-	struct ravb_tx_desc *tx_desc = NULL;
-	struct ravb_desc *desc = NULL;
+	struct ravb_ex_rx_desc *rx_desc;
+	struct ravb_tx_desc *tx_desc;
+	struct ravb_desc *desc;
 	int rx_ring_size = sizeof(*rx_desc) * priv->num_rx_ring[q];
 	int tx_ring_size = sizeof(*tx_desc) * priv->num_tx_ring[q];
 	struct sk_buff *skb;
@@ -435,7 +435,7 @@ static int ravb_tx_free(struct net_devic
 	struct net_device_stats *stats = &priv->stats[q];
 	struct ravb_tx_desc *desc;
 	int free_num = 0;
-	int entry = 0;
+	int entry;
 	u32 size;
 
 	for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
@@ -508,8 +508,8 @@ static bool ravb_rx(struct net_device *n
 	struct sk_buff *skb;
 	dma_addr_t dma_addr;
 	struct timespec64 ts;
-	u16 pkt_len = 0;
 	u8  desc_status;
+	u16 pkt_len;
 	int limit;
 
 	boguscnt = min(boguscnt, *quota);
@@ -1272,8 +1272,8 @@ static void ravb_tx_timeout_work(struct
 static netdev_tx_t ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
-	struct ravb_tstamp_skb *ts_skb = NULL;
 	u16 q = skb_get_queue_mapping(skb);
+	struct ravb_tstamp_skb *ts_skb;
 	struct ravb_tx_desc *desc;
 	unsigned long flags;
 	u32 dma_addr;
