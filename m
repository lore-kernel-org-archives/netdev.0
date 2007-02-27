From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] jmr3927: do not call tc35815_killall().
Date: Tue, 27 Feb 2007 18:15:01 +0000
Message-ID: <20070227181501.GA10897@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:60119 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbXB0SPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 13:15:11 -0500
Received: from localhost.localdomain ([127.0.0.1]:6093 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20039171AbXB0SPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 18:15:09 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to stop tc35815 before resetting the board.  This fixes the
build of tc35815 as a module.  This also means there is no caller of
tc35815_killall left, so remove that function also.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/arch/mips/jmr3927/rbhma3100/setup.c b/arch/mips/jmr3927/rbhma3100/setup.c
index 7ca3d6d..ecabe5b 100644
--- a/arch/mips/jmr3927/rbhma3100/setup.c
+++ b/arch/mips/jmr3927/rbhma3100/setup.c
@@ -137,10 +137,6 @@ int jmr3927_ccfg_toeon = 0;
 
 static inline void do_reset(void)
 {
-#ifdef CONFIG_TC35815
-	extern void tc35815_killall(void);
-	tc35815_killall();
-#endif
 #if 1	/* Resetting PCI bus */
 	jmr3927_ioc_reg_out(0, JMR3927_IOC_RESET_ADDR);
 	jmr3927_ioc_reg_out(JMR3927_IOC_RESET_PCI, JMR3927_IOC_RESET_ADDR);
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 81ed82f..911ff51 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1703,19 +1703,6 @@ static void tc35815_chip_init(struct net_device *dev)
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
-/* XXX */
-void
-tc35815_killall(void)
-{
-	struct net_device *dev;
-
-	for (dev = root_tc35815_dev; dev; dev = ((struct tc35815_local *)dev->priv)->next_module) {
-		if (dev->flags&IFF_UP){
-			dev->stop(dev);
-		}
-	}
-}
-
 static struct pci_driver tc35815_driver = {
 	.name = TC35815_MODULE_NAME,
 	.probe = tc35815_probe,
