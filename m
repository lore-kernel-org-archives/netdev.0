From: Philippe De Muyter <phdm@macqel.be>
Subject: [PATCH] sundance: small cleanup
Date: Thu, 3 Aug 2006 18:42:15 +0200
Message-ID: <20060803184215.A23519@mail.macqel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.macqel.be ([194.78.208.39]:47630 "EHLO mail.macqel.be")
	by vger.kernel.org with ESMTP id S964851AbWHCQmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 12:42:17 -0400
Received: (from phdm@localhost)
	by mail.macqel.be (8.11.0/8.11.0/SuSE Linux 8.11.0-0.4) id k73GgFk23716
	for netdev@vger.kernel.org; Thu, 3 Aug 2006 18:42:15 +0200
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch uses the sundance_reset function everywhere a reset is done,
and adds a link to the archives of the original mailing list.

Signed-off-by: Philippe De Muyter <phdm@macqel.be>

diff -r 9062402c439c drivers/net/sundance.c
--- a/drivers/net/sundance.c	Thu Aug  3 12:35:26 2006 +0700
+++ b/drivers/net/sundance.c	Thu Aug  3 18:17:31 2006 +0200
@@ -17,6 +17,8 @@
 	Support and updates available at
 	http://www.scyld.com/network/sundance.html
 	[link no longer provides useful info -jgarzik]
+	Archives of the mailing list are still available at
+	http://www.beowulf.org/pipermail/netdrivers/
 
 */
 
@@ -646,7 +648,7 @@ static int __devinit sundance_probe1 (st
 	/* Reset the chip to erase previous misconfiguration. */
 	if (netif_msg_hw(np))
 		printk("ASIC Control is %x.\n", ioread32(ioaddr + ASICCtrl));
-	iowrite16(0x00ff, ioaddr + ASICCtrl + 2);
+	sundance_reset(dev, 0x00ff << 16);
 	if (netif_msg_hw(np))
 		printk("ASIC Control is now %x.\n", ioread32(ioaddr + ASICCtrl));
 
@@ -1075,13 +1077,8 @@ reset_tx (struct net_device *dev)
 	
 	/* Reset tx logic, TxListPtr will be cleaned */
 	iowrite16 (TxDisable, ioaddr + MACCtrl1);
-	iowrite16 (TxReset | DMAReset | FIFOReset | NetworkReset,
-			ioaddr + ASICCtrl + 2);
-	for (i=50; i > 0; i--) {
-		if ((ioread16(ioaddr + ASICCtrl + 2) & ResetBusy) == 0)
-			break;
-		mdelay(1);
-	}
+	sundance_reset(dev, (NetworkReset|FIFOReset|DMAReset|TxReset) << 16);
+
 	/* free all tx skbuff */
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		skb = np->tx_skbuff[i];
