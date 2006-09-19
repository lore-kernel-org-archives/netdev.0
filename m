From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Tue, 19 Sep 2006 11:54:49 +1000
Message-ID: <20060919115449.247105cd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:57559 "EHLO smtps.tip.net.au")
	by vger.kernel.org with ESMTP id S1752009AbWISBzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 21:55:18 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On powerpc and ppc, insl_ns and insl are identical as are outsl_ns and
outsl, so remove the conditional use of insl_ns and outsl_ns.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/3c509.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

This is in anticipation of removing the insl_ns and outsl_ns definitions
which are powerpc sepcific patches.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index cbdae54..add6381 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -879,11 +879,7 @@ #endif
 	outw(skb->len, ioaddr + TX_FIFO);
 	outw(0x00, ioaddr + TX_FIFO);
 	/* ... and the packet rounded to a doubleword. */
-#ifdef  __powerpc__
-	outsl_ns(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
-#else
 	outsl(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
-#endif
 
 	dev->trans_start = jiffies;
 	if (inw(ioaddr + TX_FREE) > 1536)
@@ -1103,13 +1099,8 @@ el3_rx(struct net_device *dev)
 				skb_reserve(skb, 2);     /* Align IP on 16 byte */
 
 				/* 'skb->data' points to the start of sk_buff data area. */
-#ifdef  __powerpc__
-				insl_ns(ioaddr+RX_FIFO, skb_put(skb,pkt_len),
-							   (pkt_len + 3) >> 2);
-#else
 				insl(ioaddr + RX_FIFO, skb_put(skb,pkt_len),
 					 (pkt_len + 3) >> 2);
-#endif
 
 				outw(RxDiscard, ioaddr + EL3_CMD); /* Pop top Rx packet. */
 				skb->protocol = eth_type_trans(skb,dev);
-- 
1.4.2.1

