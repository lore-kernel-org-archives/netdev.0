From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 07/12] tg3: Reduce indent level of
 tg3_rx_prodring_alloc
Date: Wed, 17 Feb 2010 17:17:00 -0800
Message-ID: <1266455825-16150-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3729 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754244Ab0BRBRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:17:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an inverted "jumbo ring enable" test and jumps to the exit
if it succeeds.  The change reduces the indent level of the remaining
code making it more readable.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   48 ++++++++++++++++++++++++------------------------
 1 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 09e3af0..c38143b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6087,31 +6087,31 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 
 	memset(tpr->rx_jmb, 0, TG3_RX_JUMBO_RING_BYTES);
 
-	if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) {
-		for (i = 0; i < TG3_RX_JUMBO_RING_SIZE; i++) {
-			struct tg3_rx_buffer_desc *rxd;
-
-			rxd = &tpr->rx_jmb[i].std;
-			rxd->idx_len = TG3_RX_JMB_DMA_SZ << RXD_LEN_SHIFT;
-			rxd->type_flags = (RXD_FLAG_END << RXD_FLAGS_SHIFT) |
-				RXD_FLAG_JUMBO;
-			rxd->opaque = (RXD_OPAQUE_RING_JUMBO |
-			       (i << RXD_OPAQUE_INDEX_SHIFT));
-		}
+	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE))
+		goto done;
 
-		for (i = 0; i < tp->rx_jumbo_pending; i++) {
-			if (tg3_alloc_rx_skb(tp, tpr, RXD_OPAQUE_RING_JUMBO,
-					     i) < 0) {
-				printk(KERN_WARNING PFX
-				       "%s: Using a smaller RX jumbo ring, "
-				       "only %d out of %d buffers were "
-				       "allocated successfully.\n",
-				       tp->dev->name, i, tp->rx_jumbo_pending);
-				if (i == 0)
-					goto initfail;
-				tp->rx_jumbo_pending = i;
-				break;
-			}
+	for (i = 0; i < TG3_RX_JUMBO_RING_SIZE; i++) {
+		struct tg3_rx_buffer_desc *rxd;
+
+		rxd = &tpr->rx_jmb[i].std;
+		rxd->idx_len = TG3_RX_JMB_DMA_SZ << RXD_LEN_SHIFT;
+		rxd->type_flags = (RXD_FLAG_END << RXD_FLAGS_SHIFT) |
+				  RXD_FLAG_JUMBO;
+		rxd->opaque = (RXD_OPAQUE_RING_JUMBO |
+		       (i << RXD_OPAQUE_INDEX_SHIFT));
+	}
+
+	for (i = 0; i < tp->rx_jumbo_pending; i++) {
+		if (tg3_alloc_rx_skb(tp, tpr, RXD_OPAQUE_RING_JUMBO, i) < 0) {
+			printk(KERN_WARNING PFX
+			       "%s: Using a smaller RX jumbo ring, "
+			       "only %d out of %d buffers were "
+			       "allocated successfully.\n",
+			       tp->dev->name, i, tp->rx_jumbo_pending);
+			if (i == 0)
+				goto initfail;
+			tp->rx_jumbo_pending = i;
+			break;
 		}
 	}
 
-- 
1.6.4.4


