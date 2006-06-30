From: akpm@osdl.org
Subject: [patch 4/5] NI5010 netcard cleanup
Date: Fri, 30 Jun 2006 02:25:07 -0700
Message-ID: <200606300925.k5U9P7AI001395@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	andi@rhlx01.fht-esslingen.de, andi@lisas.de, bunk@stusta.de,
	jvbest@qv3pluto.leidenuniv.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26512 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751682AbWF3J1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 05:27:23 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>

- updated MAINTAINERS entry to new format
- updated Jan-Pascal's (ACKed) and my email address
- driver cleanup/modernization (runtime-, not hardware-tested)

[bunk@stusta.de: build fix]
Signed-off-by: Andreas Mohr <andi@lisas.de>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Jan-Pascal van Best <jvbest@qv3pluto.leidenuniv.nl>
Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 MAINTAINERS          |    7 +++--
 drivers/net/ni5010.c |   52 ++++++++++++++++++-----------------------
 2 files changed, 28 insertions(+), 31 deletions(-)

diff -puN drivers/net/ni5010.c~ni5010-netcard-cleanup drivers/net/ni5010.c
--- a/drivers/net/ni5010.c~ni5010-netcard-cleanup
+++ a/drivers/net/ni5010.c
@@ -1,17 +1,12 @@
 /*	ni5010.c: A network driver for the MiCom-Interlan NI5010 ethercard.
  *
- *	Copyright 1996,1997 Jan-Pascal van Best and Andreas Mohr.
+ *	Copyright 1996,1997,2006 Jan-Pascal van Best and Andreas Mohr.
  *
  *	This software may be used and distributed according to the terms
  *	of the GNU General Public License, incorporated herein by reference.
  *
  * 	The authors may be reached as:
- *		jvbest@wi.leidenuniv.nl		a.mohr@mailto.de
- * 	or by snail mail as
- * 		Jan-Pascal van Best		Andreas Mohr
- *		Klikspaanweg 58-4		Stauferstr. 6
- *		2324 LZ  Leiden			D-71272 Renningen
- *		The Netherlands			Germany
+ *		janpascal@vanbest.org		andi@lisas.de
  *
  *	Sources:
  * 	 	Donald Becker's "skeleton.c"
@@ -27,8 +22,9 @@
  *	970503	v0.93: Fixed auto-irq failure on warm reboot (JB)
  *	970623	v1.00: First kernel version (AM)
  *	970814	v1.01: Added detection of onboard receive buffer size (AM)
+ *	060611	v1.02: slight cleanup: email addresses, driver modernization.
  *	Bugs:
- *		- None known...
+ *		- not SMP-safe (no locking of I/O accesses)
  *		- Note that you have to patch ifconfig for the new /proc/net/dev
  *		format. It gives incorrect stats otherwise.
  *
@@ -39,7 +35,7 @@
  *		Complete merge with Andreas' driver
  *		Implement ring buffers (Is this useful? You can't squeeze
  *			too many packet in a 2k buffer!)
- *		Implement DMA (Again, is this useful? Some docs says DMA is
+ *		Implement DMA (Again, is this useful? Some docs say DMA is
  *			slower than programmed I/O)
  *
  *	Compile with:
@@ -47,7 +43,7 @@
  *			-DMODULE -c ni5010.c 
  *
  *	Insert with e.g.:
- *		insmod ni5010.o io=0x300 irq=5 	
+ *		insmod ni5010.ko io=0x300 irq=5
  */
 
 #include <linux/module.h>
@@ -69,15 +65,15 @@
 
 #include "ni5010.h"
 
-static const char *boardname = "NI5010";
-static char *version =
-	"ni5010.c: v1.00 06/23/97 Jan-Pascal van Best and Andreas Mohr\n";
+static const char boardname[] = "NI5010";
+static char version[] __initdata =
+	"ni5010.c: v1.02 20060611 Jan-Pascal van Best and Andreas Mohr\n";
 	
 /* bufsize_rcv == 0 means autoprobing */
 static unsigned int bufsize_rcv;
 
-#define jumpered_interrupts	/* IRQ line jumpered on board */
-#undef jumpered_dma		/* No DMA used */
+#define JUMPERED_INTERRUPTS	/* IRQ line jumpered on board */
+#undef JUMPERED_DMA		/* No DMA used */
 #undef FULL_IODETECT		/* Only detect in portlist */
 
 #ifndef FULL_IODETECT
@@ -281,7 +277,7 @@ static int __init ni5010_probe1(struct n
 
 	PRINTK2((KERN_DEBUG "%s: I/O #4 passed!\n", dev->name));
 
-#ifdef jumpered_interrupts
+#ifdef JUMPERED_INTERRUPTS
 	if (dev->irq == 0xff)
 		;
 	else if (dev->irq < 2) {
@@ -305,7 +301,7 @@ static int __init ni5010_probe1(struct n
 	} else if (dev->irq == 2) {
 		dev->irq = 9;
 	}
-#endif	/* jumpered_irq */
+#endif	/* JUMPERED_INTERRUPTS */
 	PRINTK2((KERN_DEBUG "%s: I/O #9 passed!\n", dev->name));
 
 	/* DMA is not supported (yet?), so no use detecting it */
@@ -334,7 +330,7 @@ static int __init ni5010_probe1(struct n
         	outw(0, IE_GP);		/* Point GP at start of packet */
         	outb(0, IE_RBUF);	/* set buffer byte 0 to 0 again */
 	}
-        printk("// bufsize rcv/xmt=%d/%d\n", bufsize_rcv, NI5010_BUFSIZE);
+        printk("-> bufsize rcv/xmt=%d/%d\n", bufsize_rcv, NI5010_BUFSIZE);
 	memset(dev->priv, 0, sizeof(struct ni5010_local));
 	
 	dev->open		= ni5010_open;
@@ -354,11 +350,9 @@ static int __init ni5010_probe1(struct n
 	outb(0xff, EDLC_XCLR); 	/* Kill all pending xmt interrupts */
 
 	printk(KERN_INFO "%s: NI5010 found at 0x%x, using IRQ %d", dev->name, ioaddr, dev->irq);
-	if (dev->dma) printk(" & DMA %d", dev->dma);
+	if (dev->dma)
+		printk(" & DMA %d", dev->dma);
 	printk(".\n");
-
-	printk(KERN_INFO "Join the NI5010 driver development team!\n");
-	printk(KERN_INFO "Mail to a.mohr@mailto.de or jvbest@wi.leidenuniv.nl\n");
 	return 0;
 out:
 	release_region(dev->base_addr, NI5010_IO_EXTENT);
@@ -371,7 +365,7 @@ out:
  *
  * This routine should set everything up anew at each open, even
  * registers that "should" only need to be set once at boot, so that
- * there is non-reboot way to recover if something goes wrong.
+ * there is a non-reboot way to recover if something goes wrong.
  */
    
 static int ni5010_open(struct net_device *dev)
@@ -390,13 +384,13 @@ static int ni5010_open(struct net_device
          * Always allocate the DMA channel after the IRQ,
          * and clean up on failure.
          */
-#ifdef jumpered_dma
+#ifdef JUMPERED_DMA
         if (request_dma(dev->dma, cardname)) {
 		printk(KERN_WARNING "%s: Cannot get dma %#2x\n", dev->name, dev->dma);
                 free_irq(dev->irq, NULL);
                 return -EAGAIN;
         }
-#endif	/* jumpered_dma */
+#endif	/* JUMPERED_DMA */
 
 	PRINTK3((KERN_DEBUG "%s: passed open() #2\n", dev->name));
 	/* Reset the hardware here.  Don't forget to set the station address. */
@@ -633,7 +627,7 @@ static int ni5010_close(struct net_devic
 	int ioaddr = dev->base_addr;
 
 	PRINTK2((KERN_DEBUG "%s: entering ni5010_close\n", dev->name));
-#ifdef jumpered_interrupts	
+#ifdef JUMPERED_INTERRUPTS
 	free_irq(dev->irq, NULL);
 #endif
 	/* Put card in held-RESET state */
@@ -771,7 +765,7 @@ module_param(irq, int, 0);
 MODULE_PARM_DESC(io, "ni5010 I/O base address");
 MODULE_PARM_DESC(irq, "ni5010 IRQ number");
 
-int init_module(void)
+static int __init ni5010_init_module(void)
 {
 	PRINTK2((KERN_DEBUG "%s: entering init_module\n", boardname));
 	/*
@@ -792,13 +786,15 @@ int init_module(void)
         return 0;
 }
 
-void cleanup_module(void)
+static void __exit ni5010_cleanup_module(void)
 {
 	PRINTK2((KERN_DEBUG "%s: entering cleanup_module\n", boardname));
 	unregister_netdev(dev_ni5010);
 	release_region(dev_ni5010->base_addr, NI5010_IO_EXTENT);
 	free_netdev(dev_ni5010);
 }
+module_init(ni5010_init_module);
+module_exit(ni5010_cleanup_module);
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
 
diff -puN MAINTAINERS~ni5010-netcard-cleanup MAINTAINERS
--- a/MAINTAINERS~ni5010-netcard-cleanup
+++ a/MAINTAINERS
@@ -2062,9 +2062,10 @@ L:	linux-kernel@vger.kernel.org
 S:	Maintained
 
 NI5010 NETWORK DRIVER
-P:	Jan-Pascal van Best and Andreas Mohr
-M:	Jan-Pascal van Best <jvbest@qv3pluto.leidenuniv.nl>
-M:	Andreas Mohr <100.30936@germany.net>
+P:	Jan-Pascal van Best
+M:	janpascal@vanbest.org
+P:	Andreas Mohr
+M:	andi@lisas.de
 L:	netdev@vger.kernel.org
 S:	Maintained
 
_
