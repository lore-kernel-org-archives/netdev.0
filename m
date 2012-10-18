From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 11/14] net/at91_ether: use macb dma description struct
Date: Thu, 18 Oct 2012 23:01:16 +0200
Message-ID: <1350594079-4337-12-git-send-email-manabian@gmail.com>
References: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:57738 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932568Ab2JRVBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 17:01:44 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so6136432lag.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 14:01:43 -0700 (PDT)
In-Reply-To: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/at91_ether.c | 6 +++---
 drivers/net/ethernet/cadence/macb.h       | 7 +------
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index f340d24..8204b8a 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -157,7 +157,7 @@ static void at91ether_start(struct net_device *dev)
 
 	for (i = 0; i < MAX_RX_DESCR; i++) {
 		dlist->descriptors[i].addr = (unsigned int) &dlist_phys->recv_buf[i][0];
-		dlist->descriptors[i].size = 0;
+		dlist->descriptors[i].ctrl = 0;
 	}
 
 	/* Set the Wrap bit on the last descriptor */
@@ -311,7 +311,7 @@ static void at91ether_rx(struct net_device *dev)
 	dlist = lp->dlist;
 	while (dlist->descriptors[lp->rxBuffIndex].addr & MACB_BIT(RX_USED)) {
 		p_recv = dlist->recv_buf[lp->rxBuffIndex];
-		pktlen = dlist->descriptors[lp->rxBuffIndex].size & 0x7ff;	/* Length of frame including FCS */
+		pktlen = dlist->descriptors[lp->rxBuffIndex].ctrl & 0x7ff;	/* Length of frame including FCS */
 		skb = netdev_alloc_skb(dev, pktlen + 2);
 		if (skb != NULL) {
 			skb_reserve(skb, 2);
@@ -326,7 +326,7 @@ static void at91ether_rx(struct net_device *dev)
 			printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n", dev->name);
 		}
 
-		if (dlist->descriptors[lp->rxBuffIndex].size & MACB_BIT(RX_MHASH_MATCH))
+		if (dlist->descriptors[lp->rxBuffIndex].ctrl & MACB_BIT(RX_MHASH_MATCH))
 			dev->stats.multicast++;
 
 		dlist->descriptors[lp->rxBuffIndex].addr &= ~MACB_BIT(RX_USED);	/* reset ownership bit */
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 2710562..31a877a 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -504,16 +504,11 @@ struct gem_stats {
 	u32	rx_udp_checksum_errors;
 };
 
-struct rbf_t {
-	unsigned int addr;
-	unsigned long size;
-};
-
 #define MAX_RBUFF_SZ	0x600		/* 1518 rounded up */
 #define MAX_RX_DESCR	9		/* max number of receive buffers */
 
 struct recv_desc_bufs {
-	struct rbf_t descriptors[MAX_RX_DESCR];		/* must be on sizeof (rbf_t) boundary */
+	struct dma_desc descriptors[MAX_RX_DESCR];	/* must be on sizeof (dma_desc) boundary */
 	char recv_buf[MAX_RX_DESCR][MAX_RBUFF_SZ];	/* must be on long boundary */
 };
 
-- 
1.7.12.3
