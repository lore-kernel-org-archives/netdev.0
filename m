From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 20/24 for-2.6.25] DM9000: Remove redudant use of "& 0xff"
Date: Tue, 05 Feb 2008 00:02:19 +0000
Message-ID: <20080205000818.540373091@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58734 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758837AbYBEAIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:24 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-cleanup-remove-ands.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The writing of the data should implicitly truncate
the data to 8bits, so do not bother with the ands
in the code.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -817,8 +817,8 @@ dm9000_start_xmit(struct sk_buff *skb, s
 	/* TX control: First packet immediately send, second packet queue */
 	if (db->tx_pkt_cnt == 1) {
 		/* Set TX length to DM9000 */
-		iow(db, DM9000_TXPLL, skb->len & 0xff);
-		iow(db, DM9000_TXPLH, (skb->len >> 8) & 0xff);
+		iow(db, DM9000_TXPLL, skb->len);
+		iow(db, DM9000_TXPLH, skb->len >> 8);
 
 		/* Issue TX polling command */
 		iow(db, DM9000_TCR, TCR_TXREQ);	/* Cleared after TX complete */
@@ -893,8 +893,8 @@ dm9000_tx_done(struct net_device *dev, b
 
 		/* Queue packet check & send */
 		if (db->tx_pkt_cnt > 0) {
-			iow(db, DM9000_TXPLL, db->queue_pkt_len & 0xff);
-			iow(db, DM9000_TXPLH, (db->queue_pkt_len >> 8) & 0xff);
+			iow(db, DM9000_TXPLL, db->queue_pkt_len);
+			iow(db, DM9000_TXPLH, db->queue_pkt_len >> 8);
 			iow(db, DM9000_TCR, TCR_TXREQ);
 			dev->trans_start = jiffies;
 		}
@@ -1278,8 +1278,8 @@ dm9000_phy_write(struct net_device *dev,
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
