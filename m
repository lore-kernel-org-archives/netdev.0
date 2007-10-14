From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] SAA9730: Fix build
Date: Sun, 14 Oct 2007 14:13:58 +0100
Message-ID: <20071014131358.GA19955@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:37691 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757513AbXJOKZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 06:25:44 -0400
Received: from localhost.localdomain ([127.0.0.1]:20683 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20034788AbXJOKZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 11:25:43 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix build breakage by the recent statistics cleanup in cset
09f75cd7bf13720738e6a196cc0107ce9a5bd5a0.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/saa9730.c b/drivers/net/saa9730.c
index 14361e8..c65199d 100644
--- a/drivers/net/saa9730.c
+++ b/drivers/net/saa9730.c
@@ -97,13 +97,16 @@ static void evm_saa9730_unblock_lan_int(struct lan_saa9730_private *lp)
 	       &lp->evm_saa9730_regs->InterruptBlock1);
 }
 
-static void __attribute_used__ show_saa9730_regs(struct lan_saa9730_private *lp)
+static void __used show_saa9730_regs(struct net_device *dev)
 {
+	struct lan_saa9730_private *lp = netdev_priv(dev);
 	int i, j;
+
 	printk("TxmBufferA = %p\n", lp->TxmBuffer[0][0]);
 	printk("TxmBufferB = %p\n", lp->TxmBuffer[1][0]);
 	printk("RcvBufferA = %p\n", lp->RcvBuffer[0][0]);
 	printk("RcvBufferB = %p\n", lp->RcvBuffer[1][0]);
+
 	for (i = 0; i < LAN_SAA9730_BUFFERS; i++) {
 		for (j = 0; j < LAN_SAA9730_TXM_Q_SIZE; j++) {
 			printk("TxmBuffer[%d][%d] = %x\n", i, j,
@@ -146,11 +149,13 @@ static void __attribute_used__ show_saa9730_regs(struct lan_saa9730_private *lp)
 	       readl(&lp->lan_saa9730_regs->RxCtl));
 	printk("lp->lan_saa9730_regs->RxStatus = %x\n",
 	       readl(&lp->lan_saa9730_regs->RxStatus));
+
 	for (i = 0; i < LAN_SAA9730_CAM_DWORDS; i++) {
 		writel(i, &lp->lan_saa9730_regs->CamAddress);
 		printk("lp->lan_saa9730_regs->CamData = %x\n",
 		       readl(&lp->lan_saa9730_regs->CamData));
 	}
+
 	printk("dev->stats.tx_packets = %lx\n", dev->stats.tx_packets);
 	printk("dev->stats.tx_errors = %lx\n", dev->stats.tx_errors);
 	printk("dev->stats.tx_aborted_errors = %lx\n",
@@ -855,7 +860,7 @@ static void lan_saa9730_tx_timeout(struct net_device *dev)
 	/* Transmitter timeout, serious problems */
 	dev->stats.tx_errors++;
 	printk("%s: transmit timed out, reset\n", dev->name);
-	/*show_saa9730_regs(lp); */
+	/*show_saa9730_regs(dev); */
 	lan_saa9730_restart(lp);
 
 	dev->trans_start = jiffies;
