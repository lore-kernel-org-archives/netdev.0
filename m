From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/8] tg3: Remove tp->rx_offset term when
 unneeded
Date: Wed, 31 Aug 2011 14:44:49 -0700
Message-ID: <1314827094-29714-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2588 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932172Ab1HaRzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 13:55:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the tp->rx_offset term if NET_IP_ALIGN is defined to
zero.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ab4c598..e2acf9a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -187,6 +187,12 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 	#define TG3_RX_COPY_THRESH(tp)	((tp)->rx_copy_thresh)
 #endif
 
+#if (NET_IP_ALIGN != 0)
+#define TG3_RX_OFFSET(tp)	((tp)->rx_offset)
+#else
+#define TG3_RX_OFFSET(tp)	0
+#endif
+
 /* minimum number of free TX descriptors required to wake up TX process */
 #define TG3_TX_WAKEUP_THRESH(tnapi)		((tnapi)->tx_pending / 4)
 #define TG3_TX_BD_DMA_MAX		4096
@@ -4984,11 +4990,11 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
 	 * Callers depend upon this behavior and assume that
 	 * we leave everything unchanged if we fail.
 	 */
-	skb = netdev_alloc_skb(tp->dev, skb_size + tp->rx_offset);
+	skb = netdev_alloc_skb(tp->dev, skb_size + TG3_RX_OFFSET(tp));
 	if (skb == NULL)
 		return -ENOMEM;
 
-	skb_reserve(skb, tp->rx_offset);
+	skb_reserve(skb, TG3_RX_OFFSET(tp));
 
 	mapping = pci_map_single(tp->pdev, skb->data, skb_size,
 				 PCI_DMA_FROMDEVICE);
-- 
1.7.3.4
