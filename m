From: Ben Dooks <ben-linux@fluff.org>
Subject: DM9000: Remove magic numbers
Date: Thu, 17 Jul 2008 20:29:13 +0100
Message-ID: <20080717192913.003778061@fluff.org.uk>
Cc: jeff@garzik.org, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:57999 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933104AbYGQT3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 15:29:15 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-cleanups3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove magic numbers for items that we already have
defined in the register header file.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-quilt3.orig/drivers/net/dm9000.c	2008-07-17 20:12:49.000000000 +0100
+++ linux-2.6.26-quilt3/drivers/net/dm9000.c	2008-07-17 20:24:52.000000000 +0100
@@ -888,19 +888,22 @@ dm9000_rx(struct net_device *dev)
 			dev_dbg(db->dev, "RST: RX Len:%x\n", RxLen);
 		}
 
-		if (rxhdr.RxStatus & 0xbf) {
+		/* rxhdr.RxStatus is identical to RSR register. */
+		if (rxhdr.RxStatus & (RSR_FOE | RSR_CE | RSR_AE |
+				      RSR_PLE | RSR_RWTO |
+				      RSR_LCS | RSR_RF)) {
 			GoodPacket = false;
-			if (rxhdr.RxStatus & 0x01) {
+			if (rxhdr.RxStatus & RSR_FOE) {
 				if (netif_msg_rx_err(db))
 					dev_dbg(db->dev, "fifo error\n");
 				dev->stats.rx_fifo_errors++;
 			}
-			if (rxhdr.RxStatus & 0x02) {
+			if (rxhdr.RxStatus & RSR_CE) {
 				if (netif_msg_rx_err(db))
 					dev_dbg(db->dev, "crc error\n");
 				dev->stats.rx_crc_errors++;
 			}
-			if (rxhdr.RxStatus & 0x80) {
+			if (rxhdr.RxStatus & RSR_RF) {
 				if (netif_msg_rx_err(db))
 					dev_dbg(db->dev, "length error\n");
 				dev->stats.rx_length_errors++;
@@ -1067,7 +1070,7 @@ dm9000_phy_read(struct net_device *dev, 
 	/* Fill the phyxcer register into REG_0C */
 	iow(db, DM9000_EPAR, DM9000_PHY | reg);
 
-	iow(db, DM9000_EPCR, 0xc);	/* Issue phyxcer read command */
+	iow(db, DM9000_EPCR, EPCR_ERPRR | EPCR_EPOS);	/* Issue phyxcer read command */
 
 	writeb(reg_save, db->io_addr);
 	spin_unlock_irqrestore(&db->lock,flags);
@@ -1118,7 +1121,7 @@ dm9000_phy_write(struct net_device *dev,
 	iow(db, DM9000_EPDRL, value);
 	iow(db, DM9000_EPDRH, value >> 8);
 
-	iow(db, DM9000_EPCR, 0xa);	/* Issue phyxcer write command */
+	iow(db, DM9000_EPCR, EPCR_EPOS | EPCR_ERPRW);	/* Issue phyxcer write command */
 
 	writeb(reg_save, db->io_addr);
 	spin_unlock_irqrestore(&db->lock, flags);
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
