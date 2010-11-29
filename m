From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/11] forcedeth: Use print_hex_dump
Date: Mon, 29 Nov 2010 09:41:54 -0800
Message-ID: <1b70e8ee9beb0642a1a68d9f84e166dcfdfb14c8.1291051316.git.joe@perches.com>
References: <cover.1291051316.git.joe@perches.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1291051316.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the standard code to emit hex dumps.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/forcedeth.c |   54 ++++++++++++++--------------------------------
 1 files changed, 17 insertions(+), 37 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 767d1eb..1ac8b4e 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2192,15 +2192,10 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	netdev_dbg(dev, "%s: entries %d queued for transmission. tx_flags_extra: %x\n",
 		   __func__, entries, tx_flags_extra);
-	{
-		int j;
-		for (j = 0; j < 64; j++) {
-			if ((j%16) == 0)
-				dprintk("\n%03x:", j);
-			dprintk(" %02x", ((unsigned char *)skb->data)[j]);
-		}
-		dprintk("\n");
-	}
+#ifdef DEBUG
+	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 16, 1,
+		       skb->data, 64, true);
+#endif
 
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 	return NETDEV_TX_OK;
@@ -2343,15 +2338,10 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 
 	netdev_dbg(dev, "%s: entries %d queued for transmission. tx_flags_extra: %x\n",
 		   __func__, entries, tx_flags_extra);
-	{
-		int j;
-		for (j = 0; j < 64; j++) {
-			if ((j%16) == 0)
-				dprintk("\n%03x:", j);
-			dprintk(" %02x", ((unsigned char *)skb->data)[j]);
-		}
-		dprintk("\n");
-	}
+#ifdef DEBUG
+	print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 16, 1,
+		       skb->data, 64, true);
+#endif
 
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 	return NETDEV_TX_OK;
@@ -2666,16 +2656,11 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		skb = np->get_rx_ctx->skb;
 		np->get_rx_ctx->skb = NULL;
 
-		{
-			int j;
 			netdev_dbg(dev, "Dumping packet (flags 0x%x)\n", flags);
-			for (j = 0; j < 64; j++) {
-				if ((j%16) == 0 && j)
-					dprintk("\n%03x:", j);
-				dprintk(" %02x", ((unsigned char *)skb->data)[j]);
-			}
-			dprintk("\n");
-		}
+#ifdef DEBUG
+			print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET,
+				       16, 1, skb->data, 64, true);
+#endif
 		/* look at what we actually got: */
 		if (np->desc_ver == DESC_VER_1) {
 			if (likely(flags & NV_RX_DESCRIPTORVALID)) {
@@ -2793,16 +2778,11 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 		skb = np->get_rx_ctx->skb;
 		np->get_rx_ctx->skb = NULL;
 
-		{
-			int j;
-			netdev_dbg(dev, "Dumping packet (flags 0x%x)\n", flags);
-			for (j = 0; j < 64; j++) {
-				if ((j%16) == 0 && j)
-					dprintk("\n%03x:", j);
-				dprintk(" %02x", ((unsigned char *)skb->data)[j]);
-			}
-			dprintk("\n");
-		}
+		netdev_dbg(dev, "Dumping packet (flags 0x%x)\n", flags);
+#ifdef DEBUG
+		print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_OFFSET, 16, 1,
+			       skb->data, 64, true);
+#endif
 		/* look at what we actually got: */
 		if (likely(flags & NV_RX2_DESCRIPTORVALID)) {
 			len = flags & LEN_MASK_V2;
-- 
1.7.3.2.245.g03276.dirty
