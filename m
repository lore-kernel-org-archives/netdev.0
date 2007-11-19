From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 18/22] NET: DM9000: Remove redudant use of "& 0xff"
Date: Mon, 19 Nov 2007 20:39:28 +0000
Message-ID: <20071119204015.827846943@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61655 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751357AbXKSVON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:14:13 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-cleanup-remove-ands.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The writing of the data should implicitly truncate
the data to 8bits, so do not bother with the ands
in the code.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -840,8 +840,8 @@ dm9000_start_xmit(struct sk_buff *skb, s
 	/* TX control: First packet immediately send, second packet queue */
 	if (db->tx_pkt_cnt == 1) {
 		/* Set TX length to DM9000 */
-		iow(db, DM9000_TXPLL, skb->len & 0xff);
-		iow(db, DM9000_TXPLH, (skb->len >> 8) & 0xff);
+		iow(db, DM9000_TXPLL, skb->len);
+		iow(db, DM9000_TXPLH, skb->len >> 8);
 
 		/* Issue TX polling command */
 		iow(db, DM9000_TCR, TCR_TXREQ);	/* Cleared after TX complete */
@@ -919,8 +919,8 @@ dm9000_tx_done(struct net_device *dev, b
 
 		/* Queue packet check & send */
 		if (db->tx_pkt_cnt > 0) {
-			iow(db, DM9000_TXPLL, db->queue_pkt_len & 0xff);
-			iow(db, DM9000_TXPLH, (db->queue_pkt_len >> 8) & 0xff);
+			iow(db, DM9000_TXPLL, db->queue_pkt_len);
+			iow(db, DM9000_TXPLH, db->queue_pkt_len >> 8);
 			iow(db, DM9000_TCR, TCR_TXREQ);
 			dev->trans_start = jiffies;
 		}
@@ -1341,8 +1341,8 @@ dm9000_phy_write(struct net_device *dev,
 	iow(db, DM9000_EPAR, DM9000_PHY | reg);
 
 	/* Fill the written data into REG_0D & REG_0E */
-	iow(db, DM9000_EPDRL, (value & 0xff));
-	iow(db, DM9000_EPDRH, ((value >> 8) & 0xff));
+	iow(db, DM9000_EPDRL, value);
+	iow(db, DM9000_EPDRH, value >> 8);
 
 	iow(db, DM9000_EPCR, 0xa);	/* Issue phyxcer write command */
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
