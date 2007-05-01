From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: [PATCH] drivers/net/dm9000: Convert to generic boolean
Date: Tue, 1 May 2007 18:43:27 +0200 (MEST)
Message-ID: <20070501164058.5121.57783.sendpatchset@thinktank.campus.ltu.se>
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org,
	Richard Knutsson <ricknu-0@student.ltu.se>
To: tori@unhappy.mine.nu
Return-path: <netdev-owner@vger.kernel.org>
Received: from gepetto.dc.ltu.se ([130.240.42.40]:33729 "EHLO
	gepetto.dc.ltu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765AbXEAQnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 12:43:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert to generic boolean.

Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
---
Compile-tested with all(yes|mod|no)config on x86(|_64) & sparc(|64)
Diffed against Linus' git-tree.


diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 8cc1174..6fb3815 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -77,9 +77,6 @@
 
 #define DM9000_PHY		0x40	/* PHY address 0x01 */
 
-#define TRUE			1
-#define FALSE			0
-
 #define CARDNAME "dm9000"
 #define PFX CARDNAME ": "
 
@@ -896,7 +893,7 @@ dm9000_rx(struct net_device *dev)
 	struct dm9000_rxhdr rxhdr;
 	struct sk_buff *skb;
 	u8 rxbyte, *rdptr;
-	int GoodPacket;
+	bool GoodPacket;
 	int RxLen;
 
 	/* Check packet ready or not */
@@ -918,7 +915,7 @@ dm9000_rx(struct net_device *dev)
 			return;
 
 		/* A packet ready now  & Get status/length */
-		GoodPacket = TRUE;
+		GoodPacket = true;
 		writeb(DM9000_MRCMD, db->io_addr);
 
 		(db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));
@@ -927,7 +924,7 @@ dm9000_rx(struct net_device *dev)
 
 		/* Packet Status check */
 		if (RxLen < 0x40) {
-			GoodPacket = FALSE;
+			GoodPacket = false;
 			PRINTK1("Bad Packet received (runt)\n");
 		}
 
@@ -936,7 +933,7 @@ dm9000_rx(struct net_device *dev)
 		}
 
 		if (rxhdr.RxStatus & 0xbf00) {
-			GoodPacket = FALSE;
+			GoodPacket = false;
 			if (rxhdr.RxStatus & 0x100) {
 				PRINTK1("fifo error\n");
 				db->stats.rx_fifo_errors++;
