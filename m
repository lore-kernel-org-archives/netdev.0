From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 5/7] bnx2: use netdev_irqname
Date: Tue, 21 Jun 2011 10:05:46 -0700
Message-ID: <20110621170658.788401517@vyatta.com>
References: <20110621170541.309890798@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49491 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756983Ab1FURHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:07:23 -0400
Content-Disposition: inline; filename=bnx2-use-irqname.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also increase size of irq name to account for longer device names.
Original code was broken for full size names.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bnx2.c	2011-06-21 09:52:00.527951530 -0700
+++ b/drivers/net/bnx2.c	2011-06-21 09:52:58.807951497 -0700
@@ -6173,7 +6173,8 @@ bnx2_enable_msix(struct bnx2 *bp, int ms
 	bp->flags |= BNX2_FLAG_USING_MSIX | BNX2_FLAG_ONE_SHOT_MSI;
 	for (i = 0; i < total_vecs; i++) {
 		bp->irq_tbl[i].vector = msix_ent[i].vector;
-		snprintf(bp->irq_tbl[i].name, len, "%s-%d", dev->name, i);
+		netdev_irqname(bp->irq_tbl[i].name, len,
+			       dev, NETIF_IRQ_TXRX, i);
 		bp->irq_tbl[i].handler = bnx2_msi_1shot;
 	}
 }
--- a/drivers/net/bnx2.h	2011-06-21 09:53:18.331951487 -0700
+++ b/drivers/net/bnx2.h	2011-06-21 09:53:51.723951469 -0700
@@ -6657,7 +6657,7 @@ struct bnx2_irq {
 	irq_handler_t	handler;
 	unsigned int	vector;
 	u8		requested;
-	char		name[IFNAMSIZ + 2];
+	char		name[32];
 };
 
 struct bnx2_tx_ring_info {


