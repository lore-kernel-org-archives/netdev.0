From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] smc ethernet: fix section mismatch warnings
Date: Sat, 10 Jun 2006 13:30:10 -0700
Message-ID: <20060610133010.6dba30f3.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: p_gortmaker@yahoo.com, akpm <akpm@osdl.org>,
	jgarzik <jgarzik@pobox.com>, nico@cam.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:34709 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751699AbWFJUdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2006 16:33:13 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Sat, 10 Jun 2006 13:33:09 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Priority: not critical; makes init code discardable.
Removes one duplicate assignment.

Fix section mismatch warnings:
WARNING: drivers/net/smc-ultra.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x369) and 'cleanup_card'
WARNING: drivers/net/smc-ultra32.o - Section mismatch: reference to .init.text:ultra32_probe from .text between 'init_module' (at offset 0x254) and 'cleanup_module'
WARNING: drivers/net/smc9194.o - Section mismatch: reference to .init.text:smc_init from .text between 'init_module' (at offset 0x997) and 'cleanup_module'
WARNING: drivers/net/smc9194.o - Section mismatch: reference to .init.data: from .data between 'smcdev.0' (at offset 0x44) and '__param_str_io'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/smc-ultra.c   |    2 +-
 drivers/net/smc-ultra32.c |    2 +-
 drivers/net/smc9194.c     |    7 ++-----
 3 files changed, 4 insertions(+), 7 deletions(-)

--- linux-2617-rc6.orig/drivers/net/smc-ultra.c
+++ linux-2617-rc6/drivers/net/smc-ultra.c
@@ -553,7 +553,7 @@ MODULE_LICENSE("GPL");
 
 /* This is set up so that only a single autoprobe takes place per call.
 ISA device autoprobes on a running machine are not recommended. */
-int
+int __init
 init_module(void)
 {
 	struct net_device *dev;
--- linux-2617-rc6.orig/drivers/net/smc-ultra32.c
+++ linux-2617-rc6/drivers/net/smc-ultra32.c
@@ -421,7 +421,7 @@ static struct net_device *dev_ultra[MAX_
 MODULE_DESCRIPTION("SMC Ultra32 EISA ethernet driver");
 MODULE_LICENSE("GPL");
 
-int init_module(void)
+int __init init_module(void)
 {
 	int this_dev, found = 0;
 
--- linux-2617-rc6.orig/drivers/net/smc9194.c
+++ linux-2617-rc6/drivers/net/smc9194.c
@@ -732,12 +732,9 @@ static int ifport;
 struct net_device * __init smc_init(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct smc_local));
-	static struct devlist *smcdev = smc_devlist;
+	struct devlist *smcdev = smc_devlist;
 	int err = 0;
 
-#ifndef NO_AUTOPROBE
-	smcdev = smc_devlist;
-#endif
 	if (!dev)
 		return ERR_PTR(-ENODEV);
 
@@ -1607,7 +1604,7 @@ MODULE_PARM_DESC(io, "SMC 99194 I/O base
 MODULE_PARM_DESC(irq, "SMC 99194 IRQ number");
 MODULE_PARM_DESC(ifport, "SMC 99194 interface port (0-default, 1-TP, 2-AUI)");
 
-int init_module(void)
+int __init init_module(void)
 {
 	if (io == 0)
 		printk(KERN_WARNING


---
