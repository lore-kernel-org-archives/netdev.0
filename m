From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: 2/x: [NETDRV] Use driver-specific name for resources
Date: Sat, 22 May 2004 17:44:35 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040522074435.GA9628@gondor.apana.org.au>
References: <20040313025859.GA8186@gondor.apana.org.au> <405C294D.5040508@pobox.com> <20040520111937.GA21804@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040520111937.GA21804@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 20, 2004 at 09:19:37PM +1000, herbert wrote:
> 
> Thanks for the comments.
> 
> I'll split it up.  Here is the bit which conditionalises the
> builtin-only probe functions.

Here is the next part which uses a driver-specific name instead of
dev->name for resource allocations prior to netdev registration.
It also changes printks that are in direct response to errors in
resource allocations.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

diff -Nru a/drivers/net/3c501.c b/drivers/net/3c501.c
--- a/drivers/net/3c501.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/3c501.c	Sat May 22 17:40:55 2004
@@ -225,7 +225,7 @@
 	 *	Reserve I/O resource for exclusive use by this driver
 	 */
 
-	if (!request_region(ioaddr, EL1_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, EL1_IO_EXTENT, DRV_NAME))
 		return -ENODEV;
 
 	/*
diff -Nru a/drivers/net/3c503.c b/drivers/net/3c503.c
--- a/drivers/net/3c503.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/3c503.c	Sat May 22 17:40:55 2004
@@ -184,10 +184,10 @@
     static unsigned version_printed;
     unsigned long vendor_id;
 
-    if (!request_region(ioaddr, EL2_IO_EXTENT, dev->name))
+    if (!request_region(ioaddr, EL2_IO_EXTENT, DRV_NAME))
 	return -EBUSY;
 
-    if (!request_region(ioaddr + 0x400, 8, dev->name)) {
+    if (!request_region(ioaddr + 0x400, 8, DRV_NAME)) {
 	retval = -EBUSY;
 	goto out;
     }
diff -Nru a/drivers/net/3c507.c b/drivers/net/3c507.c
--- a/drivers/net/3c507.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/3c507.c	Sat May 22 17:40:55 2004
@@ -373,7 +373,7 @@
 		init_ID_done = 1;
 	}
 
-	if (!request_region(ioaddr, EL16_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, EL16_IO_EXTENT, DRV_NAME))
 		return -ENODEV;
 
 	if ((inb(ioaddr) != '*') || (inb(ioaddr + 1) != '3') || 
@@ -392,7 +392,7 @@
 
 	irq = inb(ioaddr + IRQ_CONFIG) & 0x0f;
 
-	irqval = request_irq(irq, &el16_interrupt, 0, dev->name, dev);
+	irqval = request_irq(irq, &el16_interrupt, 0, DRV_NAME, dev);
 	if (irqval) {
 		printk ("unable to get IRQ %d (irqval=%d).\n", irq, irqval);
 		retval = -EAGAIN;
diff -Nru a/drivers/net/3c523.c b/drivers/net/3c523.c
--- a/drivers/net/3c523.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/3c523.c	Sat May 22 17:40:55 2004
@@ -445,7 +445,7 @@
 			slot = mca_find_adapter(ELMC_MCA_ID, slot + 1);
 			continue;
 		}
-		if (!request_region(dev->base_addr, ELMC_IO_EXTENT, dev->name)) {
+		if (!request_region(dev->base_addr, ELMC_IO_EXTENT, DRV_NAME)) {
 			slot = mca_find_adapter(ELMC_MCA_ID, slot + 1);
 			continue;
 		}
diff -Nru a/drivers/net/3c527.c b/drivers/net/3c527.c
--- a/drivers/net/3c527.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/3c527.c	Sat May 22 17:40:55 2004
@@ -434,10 +434,10 @@
 	 *	Grab the IRQ
 	 */
 
-	err = request_irq(dev->irq, &mc32_interrupt, SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
+	err = request_irq(dev->irq, &mc32_interrupt, SA_SHIRQ | SA_SAMPLE_RANDOM, DRV_NAME, dev);
 	if (err) {
 		release_region(dev->base_addr, MC32_IO_EXTENT);
-		printk(KERN_ERR "%s: unable to get IRQ %d.\n", dev->name, dev->irq);
+		printk(KERN_ERR "%s: unable to get IRQ %d.\n", DRV_NAME, dev->irq);
 		goto err_exit_ports;
 	}
 
diff -Nru a/drivers/net/82596.c b/drivers/net/82596.c
--- a/drivers/net/82596.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/82596.c	Sat May 22 17:40:55 2004
@@ -63,6 +63,8 @@
 static char version[] __initdata =
 	"82596.c $Revision: 1.5 $\n";
 
+#define DRV_NAME	"82596"
+
 /* DEBUG flags
  */
 
@@ -1191,7 +1193,7 @@
 		/* this is easy the ethernet interface can only be at 0x300 */
 		/* first check nothing is already registered here */
 
-		if (!request_region(ioaddr, I596_TOTAL_SIZE, dev->name)) {
+		if (!request_region(ioaddr, I596_TOTAL_SIZE, DRV_NAME)) {
 			printk(KERN_ERR "82596: IO address 0x%04x in use\n", ioaddr);
 			err = -EBUSY;
 			goto out;
diff -Nru a/drivers/net/ac3200.c b/drivers/net/ac3200.c
--- a/drivers/net/ac3200.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/ac3200.c	Sat May 22 17:40:55 2004
@@ -39,6 +39,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME	"ac3200"
+
 /* Offsets from the base address. */
 #define AC_NIC_BASE	0x00
 #define AC_SA_PROM	0x16			/* The station address PROM. */
@@ -161,7 +163,7 @@
 {
 	int i, retval;
 
-	if (!request_region(ioaddr, AC_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, AC_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 	if (inb_p(ioaddr + AC_ID_PORT) == 0xff) {
@@ -205,7 +207,7 @@
 		printk(", assigning");
 	}
 
-	retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);
+	retval = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
 	if (retval) {
 		printk (" nothing! Unable to get IRQ %d.\n", dev->irq);
 		goto out1;
diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/acenic.c	Sat May 22 17:40:55 2004
@@ -85,6 +85,8 @@
 #include <asm/uaccess.h>
 
 
+#define DRV_NAME "acenic"
+
 #undef INDEX_DEBUG
 
 #ifdef CONFIG_ACENIC_OMIT_TIGON_I
@@ -1454,10 +1456,10 @@
 	}
 
 	ecode = request_irq(pdev->irq, ace_interrupt, SA_SHIRQ,
-			    dev->name, dev);
+			    DRV_NAME, dev);
 	if (ecode) {
 		printk(KERN_WARNING "%s: Requested IRQ %d is busy\n",
-		       dev->name, pdev->irq);
+		       DRV_NAME, pdev->irq);
 		goto init_error;
 	} else
 		dev->irq = pdev->irq;
diff -Nru a/drivers/net/apne.c b/drivers/net/apne.c
--- a/drivers/net/apne.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/apne.c	Sat May 22 17:40:55 2004
@@ -49,6 +49,8 @@
 
 /* ---- No user-serviceable parts below ---- */
 
+#define DRV_NAME "apne"
+
 #define NE_BASE	 (dev->base_addr)
 #define NE_CMD	 		0x00
 #define NE_DATAPORT		0x10            /* NatSemi-defined port window offset. */
@@ -168,7 +170,7 @@
 		return ERR_PTR(-ENODEV);
 	}
 
-	if (!request_region(IOBASE, 0x20, dev->name)) {
+	if (!request_region(IOBASE, 0x20, DRV_NAME)) {
 		free_netdev(dev);
 		return ERR_PTR(-EBUSY);
 	}
@@ -310,7 +312,7 @@
     dev->base_addr = ioaddr;
 
     /* Install the Interrupt handler */
-    i = request_irq(IRQ_AMIGA_PORTS, apne_interrupt, SA_SHIRQ, dev->name, dev);
+    i = request_irq(IRQ_AMIGA_PORTS, apne_interrupt, SA_SHIRQ, DRV_NAME, dev);
     if (i) return i;
 
     for(i = 0; i < ETHER_ADDR_LEN; i++) {
diff -Nru a/drivers/net/at1700.c b/drivers/net/at1700.c
--- a/drivers/net/at1700.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/at1700.c	Sat May 22 17:40:55 2004
@@ -65,6 +65,8 @@
 static char version[] __initdata =
 	"at1700.c:v1.15 4/7/98  Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
 
+#define DRV_NAME "at1700"
+
 /* Tunable parameters. */
 
 /* When to switch from the 64-entry multicast filter to Rx-all-multicast. */
@@ -322,11 +324,11 @@
 	struct net_local *lp = netdev_priv(dev);
 
 #ifndef CONFIG_X86_PC9800
-	if (!request_region(ioaddr, AT1700_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, AT1700_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 #else
 	for (i = 0; i < 0x2000; i += 0x0200) {
-		if (!request_region(ioaddr + i, 2, dev->name)) {
+		if (!request_region(ioaddr + i, 2, DRV_NAME)) {
 			while (i > 0) {
 				i -= 0x0200;
 				release_region(ioaddr + i, 2);
@@ -542,7 +544,7 @@
 	lp->jumpered = is_fmv18x;
 	lp->mca_slot = slot;
 	/* Snarf the interrupt vector now. */
-	ret = request_irq(irq, &net_interrupt, 0, dev->name, dev);
+	ret = request_irq(irq, &net_interrupt, 0, DRV_NAME, dev);
 	if (ret) {
 		printk ("  AT1700 at %#3x is unusable due to a conflict on"
 				"IRQ %d.\n", ioaddr, irq);
diff -Nru a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
--- a/drivers/net/cs89x0.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/cs89x0.c	Sat May 22 17:40:55 2004
@@ -141,6 +141,8 @@
 static char version[] __initdata =
 "cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Morton <andrewm@uow.edu.au>\n";
 
+#define DRV_NAME "cs89x0"
+
 /* First, a few definitions that the brave might change.
    A zero-terminated list of I/O addresses to be probed. Some special flags..
       Addr & 1 = Read back the address port, look for signature and reset
@@ -425,9 +427,9 @@
 
 	/* Grab the region so we can find another board if autoIRQ fails. */
 	/* WTF is going on here? */
-	if (!request_region(ioaddr & ~3, NETCARD_IO_EXTENT, dev->name)) {
+	if (!request_region(ioaddr & ~3, NETCARD_IO_EXTENT, DRV_NAME)) {
 		printk(KERN_ERR "%s: request_region(0x%x, 0x%x) failed\n",
-				dev->name, ioaddr, NETCARD_IO_EXTENT);
+				DRV_NAME, ioaddr, NETCARD_IO_EXTENT);
 		retval = -EBUSY;
 		goto out1;
 	}
diff -Nru a/drivers/net/defxx.c b/drivers/net/defxx.c
--- a/drivers/net/defxx.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/defxx.c	Sat May 22 17:40:55 2004
@@ -219,6 +219,8 @@
 static char version[] __devinitdata =
 	"defxx.c:v1.06 2003/08/04  Lawrence V. Stefani and others\n";
 
+#define DRV_NAME "defxx"
+
 #define DYNAMIC_BUFFERS 1
 
 #define SKBUFF_RX_COPYBREAK 200
@@ -435,9 +437,9 @@
 
 	bp = dev->priv;
 
-	if (!request_region (ioaddr, pdev ? PFI_K_CSR_IO_LEN : PI_ESIC_K_CSR_IO_LEN, dev->name)) {
+	if (!request_region (ioaddr, pdev ? PFI_K_CSR_IO_LEN : PI_ESIC_K_CSR_IO_LEN, DRV_NAME)) {
 		printk (KERN_ERR "%s: Cannot reserve I/O resource 0x%x @ 0x%lx, aborting\n",
-			dev->name, PFI_K_CSR_IO_LEN, ioaddr);
+			DRV_NAME, PFI_K_CSR_IO_LEN, ioaddr);
 		err = -EBUSY;
 		goto err_out;
 	}
diff -Nru a/drivers/net/e2100.c b/drivers/net/e2100.c
--- a/drivers/net/e2100.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/e2100.c	Sat May 22 17:40:55 2004
@@ -51,6 +51,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "e2100"
+
 static int e21_probe_list[] = {0x300, 0x280, 0x380, 0x220, 0};
 
 /* Offsets from the base_addr.
@@ -177,7 +179,7 @@
 	unsigned char *station_addr = dev->dev_addr;
 	static unsigned version_printed;
 
-	if (!request_region(ioaddr, E21_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, E21_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 	/* First check the station address for the Ctron prefix. */
diff -Nru a/drivers/net/eepro.c b/drivers/net/eepro.c
--- a/drivers/net/eepro.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/eepro.c	Sat May 22 17:40:55 2004
@@ -151,6 +151,8 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 
+#define DRV_NAME "eepro"
+
 #define compat_dev_kfree_skb( skb, mode ) dev_kfree_skb( (skb) )
 /* I had reports of looong delays with SLOW_DOWN defined as udelay(2) */
 #define SLOW_DOWN inb(0x80)
@@ -747,7 +749,7 @@
 	int ioaddr = dev->base_addr;
 
 	/* Grab the region so we can find another board if autoIRQ fails. */
-	if (!request_region(ioaddr, EEPRO_IO_EXTENT, dev->name)) { 
+	if (!request_region(ioaddr, EEPRO_IO_EXTENT, DRV_NAME)) { 
 		if (!autoprobe)
 			printk(KERN_WARNING "EEPRO: io-port 0x%04x in use \n",
 				ioaddr);
diff -Nru a/drivers/net/eth16i.c b/drivers/net/eth16i.c
--- a/drivers/net/eth16i.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/eth16i.c	Sat May 22 17:40:55 2004
@@ -493,7 +493,7 @@
 	int retval;
 
 	/* Let's grab the region */
-	if (!request_region(ioaddr, ETH16I_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, ETH16I_IO_EXTENT, cardname))
 		return -EBUSY;
 
 	/*
@@ -540,9 +540,9 @@
 
 	/* Try to obtain interrupt vector */
 
-	if ((retval = request_irq(dev->irq, (void *)&eth16i_interrupt, 0, dev->name, dev))) {
-		printk(KERN_WARNING "%s: %s at %#3x, but is unusable due conflicting IRQ %d.\n", 
-		       dev->name, cardname, ioaddr, dev->irq);
+	if ((retval = request_irq(dev->irq, (void *)&eth16i_interrupt, 0, cardname, dev))) {
+		printk(KERN_WARNING "%s at %#3x, but is unusable due to conflicting IRQ %d.\n", 
+		       cardname, ioaddr, dev->irq);
 		goto out;
 	}
 
diff -Nru a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
--- a/drivers/net/ewrk3.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/ewrk3.c	Sat May 22 17:40:55 2004
@@ -1271,7 +1271,7 @@
 	for (; (i < maxSlots) && (dev != NULL);
 	     iobase += EWRK3_IOP_INC, i++)
 	{
-		if (request_region(iobase, EWRK3_TOTAL_SIZE, dev->name)) {
+		if (request_region(iobase, EWRK3_TOTAL_SIZE, DRV_NAME)) {
 			if (DevicePresent(iobase) == 0) {
 				int irq = dev->irq;
 				ret = ewrk3_hw_init(dev, iobase);
@@ -1312,7 +1312,7 @@
 
 	for (i = 1; (i < maxSlots) && (dev != NULL); i++, iobase += EISA_SLOT_INC) {
 		if (EISA_signature(name, EISA_ID) == 0) {
-			if (request_region(iobase, EWRK3_TOTAL_SIZE, dev->name) &&
+			if (request_region(iobase, EWRK3_TOTAL_SIZE, DRV_NAME) &&
 			    DevicePresent(iobase) == 0) {
 				int irq = dev->irq;
 				ret = ewrk3_hw_init(dev, iobase);
diff -Nru a/drivers/net/fmv18x.c b/drivers/net/fmv18x.c
--- a/drivers/net/fmv18x.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/fmv18x.c	Sat May 22 17:40:55 2004
@@ -57,6 +57,8 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 
+#define DRV_NAME "fmv18x"
+
 static unsigned fmv18x_probe_list[] __initdata = {
 	0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x300, 0x340, 0
 };
@@ -192,7 +194,7 @@
 	   That means we have to be careful with the register values we probe for.
 	   */
 
-	if (!request_region(ioaddr, FMV18X_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, FMV18X_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 	dev->irq = irq;
@@ -224,7 +226,7 @@
 	}
 
 	/* Snarf the interrupt vector now. */
-	retval = request_irq(dev->irq, &net_interrupt, 0, dev->name, dev);
+	retval = request_irq(dev->irq, &net_interrupt, 0, DRV_NAME, dev);
 	if (retval) {
 		printk ("FMV-18x found at %#3x, but it's unusable due to a conflict on"
 				"IRQ %d.\n", ioaddr, dev->irq);
diff -Nru a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/forcedeth.c	Sat May 22 17:40:55 2004
@@ -81,6 +81,7 @@
  * superfluous timer interrupts from the nic.
  */
 #define FORCEDETH_VERSION		"0.25"
+#define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
 #include <linux/types.h>
@@ -1424,7 +1425,7 @@
 
 	pci_set_master(pci_dev);
 
-	err = pci_request_regions(pci_dev, dev->name);
+	err = pci_request_regions(pci_dev, DRV_NAME);
 	if (err < 0)
 		goto out_disable;
 
diff -Nru a/drivers/net/hp-plus.c b/drivers/net/hp-plus.c
--- a/drivers/net/hp-plus.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/hp-plus.c	Sat May 22 17:40:55 2004
@@ -37,6 +37,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "hp-plus"
+
 /* A zero-terminated list of I/O addresses to be probed. */
 static unsigned int hpplus_portlist[] __initdata =
 {0x200, 0x240, 0x280, 0x2C0, 0x300, 0x320, 0x340, 0};
@@ -178,7 +180,7 @@
 	int mem_start;
 	static unsigned version_printed;
 
-	if (!request_region(ioaddr, HP_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, HP_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 	/* Check for the HP+ signature, 50 48 0x 53. */
diff -Nru a/drivers/net/hp.c b/drivers/net/hp.c
--- a/drivers/net/hp.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/hp.c	Sat May 22 17:40:55 2004
@@ -37,6 +37,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "hp"
+
 /* A zero-terminated list of I/O addresses to be probed. */
 static unsigned int hppclan_portlist[] __initdata =
 { 0x300, 0x320, 0x340, 0x280, 0x2C0, 0x200, 0x240, 0};
@@ -139,7 +141,7 @@
 	const char *name;
 	static unsigned version_printed;
 
-	if (!request_region(ioaddr, HP_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, HP_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 	/* Check for the HP physical address, 08 00 09 xx xx xx. */
@@ -184,7 +186,7 @@
 				outb_p(irqmap[irq] | HP_RUN, ioaddr + HP_CONFIGURE);
 				outb_p( 0x00 | HP_RUN, ioaddr + HP_CONFIGURE);
 				if (irq == probe_irq_off(cookie)		 /* It's a good IRQ line! */
-					&& request_irq (irq, ei_interrupt, 0, dev->name, dev) == 0) {
+					&& request_irq (irq, ei_interrupt, 0, DRV_NAME, dev) == 0) {
 					printk(" selecting IRQ %d.\n", irq);
 					dev->irq = *irqp;
 					break;
@@ -199,7 +201,7 @@
 	} else {
 		if (dev->irq == 2)
 			dev->irq = 9;
-		if ((retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev))) {
+		if ((retval = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev))) {
 			printk (" unable to get IRQ %d.\n", dev->irq);
 			goto out;
 		}
diff -Nru a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
--- a/drivers/net/ibmlana.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/ibmlana.c	Sat May 22 17:40:55 2004
@@ -97,6 +97,8 @@
 
 #undef DEBUG
 
+#define DRV_NAME "ibmlana"
+
 /* ------------------------------------------------------------------------
  * global static data - not more since we can handle multiple boards and
  * have to pack all state info into the device struct!
@@ -951,8 +953,8 @@
 	printk(KERN_INFO "%s: IBM LAN Adapter/A found in slot %d\n", dev->name, slot + 1);
 
 	/* try to obtain I/O range */
-	if (!request_region(iobase, IBM_LANA_IORANGE, dev->name)) {
-		printk(KERN_ERR "%s: cannot allocate I/O range at %#x!\n", dev->name, iobase);
+	if (!request_region(iobase, IBM_LANA_IORANGE, DRV_NAME)) {
+		printk(KERN_ERR "%s: cannot allocate I/O range at %#x!\n", DRV_NAME, iobase);
 		startslot = slot + 1;
 		return -EBUSY;
 	}
diff -Nru a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
--- a/drivers/net/jazzsonic.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/jazzsonic.c	Sat May 22 17:40:55 2004
@@ -37,6 +37,8 @@
 #include <asm/jazz.h>
 #include <asm/jazzdma.h>
 
+#define DRV_NAME "jazzsonic"
+
 #define SREGS_PAD(n)    u16 n;
 
 #include "sonic.h"
@@ -151,7 +153,7 @@
 	int err = -ENODEV;
 	int i;
 
-	if (!request_region(base_addr, 0x100, dev->name))
+	if (!request_region(base_addr, 0x100, DRV_NAME))
 		return -EBUSY;
 	/*
 	 * get the Silicon Revision ID. If this is one of the known
diff -Nru a/drivers/net/lne390.c b/drivers/net/lne390.c
--- a/drivers/net/lne390.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/lne390.c	Sat May 22 17:40:55 2004
@@ -49,6 +49,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "lne390"
+
 static int lne390_probe1(struct net_device *dev, int ioaddr);
 
 static int lne390_open(struct net_device *dev);
@@ -112,7 +114,7 @@
 	SET_MODULE_OWNER(dev);
 
 	if (ioaddr > 0x1ff) {		/* Check a single specified location. */
-		if (!request_region(ioaddr, LNE390_IO_EXTENT, dev->name))
+		if (!request_region(ioaddr, LNE390_IO_EXTENT, DRV_NAME))
 			return -EBUSY;
 		ret = lne390_probe1(dev, ioaddr);
 		if (ret)
@@ -131,7 +133,7 @@
 
 	/* EISA spec allows for up to 16 slots, but 8 is typical. */
 	for (ioaddr = 0x1000; ioaddr < 0x9000; ioaddr += 0x1000) {
-		if (!request_region(ioaddr, LNE390_IO_EXTENT, dev->name))
+		if (!request_region(ioaddr, LNE390_IO_EXTENT, DRV_NAME))
 			continue;
 		if (lne390_probe1(dev, ioaddr) == 0)
 			return 0;
@@ -230,7 +232,7 @@
 	}
 	printk(" IRQ %d,", dev->irq);
 
-	if ((ret = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev))) {
+	if ((ret = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev))) {
 		printk (" unable to get IRQ %d.\n", dev->irq);
 		return ret;
 	}
diff -Nru a/drivers/net/lp486e.c b/drivers/net/lp486e.c
--- a/drivers/net/lp486e.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/lp486e.c	Sat May 22 17:40:55 2004
@@ -75,6 +75,8 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 
+#define DRV_NAME "lp486e"
+
 /* debug print flags */
 #define LOG_SRCDST    0x80000000
 #define LOG_STATINT   0x40000000
@@ -970,7 +972,7 @@
 		return -ENODEV;
 	probed++;
 
-	if (!request_region(IOADDR, LP486E_TOTAL_SIZE, dev->name)) {
+	if (!request_region(IOADDR, LP486E_TOTAL_SIZE, DRV_NAME)) {
 		printk(KERN_ERR "lp486e: IO address 0x%x in use\n", IOADDR);
 		return -EBUSY;
 	}
diff -Nru a/drivers/net/natsemi.c b/drivers/net/natsemi.c
--- a/drivers/net/natsemi.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/natsemi.c	Sat May 22 17:40:55 2004
@@ -766,7 +766,7 @@
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	i = pci_request_regions(pdev, dev->name);
+	i = pci_request_regions(pdev, DRV_NAME);
 	if (i)
 		goto err_pci_request_regions;
 
diff -Nru a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
--- a/drivers/net/ne-h8300.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/ne-h8300.c	Sat May 22 17:40:55 2004
@@ -34,6 +34,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "ne-h8300"
+
 /* Some defines that people can play with if so inclined. */
 
 /* Do we perform extra sanity checks on stuff ? */
@@ -202,7 +204,7 @@
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
 	unsigned char bus_width;
 
-	if (!request_region(ioaddr, NE_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, NE_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 	reg0 = inb_p(ioaddr);
diff -Nru a/drivers/net/ne.c b/drivers/net/ne.c
--- a/drivers/net/ne.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/ne.c	Sat May 22 17:40:55 2004
@@ -55,6 +55,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "ne"
+
 /* Some defines that people can play with if so inclined. */
 
 /* Do we support clones that don't adhere to 14,15 of the SAprom ? */
@@ -286,7 +288,7 @@
 	int reg0, ret;
 	static unsigned version_printed;
 
-	if (!request_region(ioaddr, NE_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, NE_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 	reg0 = inb_p(ioaddr);
diff -Nru a/drivers/net/ne2.c b/drivers/net/ne2.c
--- a/drivers/net/ne2.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/ne2.c	Sat May 22 17:40:55 2004
@@ -82,6 +82,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "ne2"
+
 /* Some defines that people can play with if so inclined. */
 
 /* Do we perform extra sanity checks on stuff ? */
@@ -370,7 +372,7 @@
 		irq = irqs[(POS & 0x60)>>5];
 	}
 
-	if (!request_region(base_addr, NE_IO_EXTENT, dev->name))
+	if (!request_region(base_addr, NE_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 #ifdef DEBUG
@@ -472,7 +474,7 @@
 
 	/* Snarf the interrupt now.  There's no point in waiting since we cannot
 	   share and the board will usually be enabled. */
-	retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);
+	retval = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
 	if (retval) {
 		printk (" unable to get IRQ %d (irqval=%d).\n", 
 				dev->irq, retval);
diff -Nru a/drivers/net/ne2k_cbus.c b/drivers/net/ne2k_cbus.c
--- a/drivers/net/ne2k_cbus.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/ne2k_cbus.c	Sat May 22 17:40:55 2004
@@ -37,6 +37,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "ne2k_cbus"
+
 /* Some defines that people can play with if so inclined. */
 
 /* Do we support clones that don't adhere to 14,15 of the SAprom ? */
@@ -265,7 +267,7 @@
 
 	for (rlist = hw->regionlist; rlist->range; rlist++)
 		if (!request_region(ioaddr + rlist->start,
-					rlist->range, dev->name)) {
+					rlist->range, DRV_NAME)) {
 			ret = -EBUSY;
 			goto err_out;
 		}
diff -Nru a/drivers/net/ne3210.c b/drivers/net/ne3210.c
--- a/drivers/net/ne3210.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/ne3210.c	Sat May 22 17:40:55 2004
@@ -45,6 +45,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "ne3210"
+
 static int ne3210_open(struct net_device *dev);
 static int ne3210_close(struct net_device *dev);
 
@@ -111,13 +113,13 @@
 	device->driver_data = dev;
 	ioaddr = edev->base_addr;
 
-	if (!request_region(ioaddr, NE3210_IO_EXTENT, dev->name)) {
+	if (!request_region(ioaddr, NE3210_IO_EXTENT, DRV_NAME)) {
 		retval = -EBUSY;
 		goto out;
 	}
 
 	if (!request_region(ioaddr + NE3210_CFG1,
-			    NE3210_CFG_EXTENT, dev->name)) {
+			    NE3210_CFG_EXTENT, DRV_NAME)) {
 		retval = -EBUSY;
 		goto out1;
 	}
@@ -140,7 +142,7 @@
 	dev->irq = irq_map[(inb(ioaddr + NE3210_CFG2) >> 3) & 0x07];
 	printk(".\nne3210.c: using IRQ %d, ", dev->irq);
 
-	retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);
+	retval = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
 	if (retval) {
 		printk (" unable to get IRQ %d.\n", dev->irq);
 		goto out2;
@@ -163,7 +165,7 @@
 		}
 	}
 	
-	if (!request_mem_region (phys_mem, NE3210_STOP_PG*0x100, dev->name)) {
+	if (!request_mem_region (phys_mem, NE3210_STOP_PG*0x100, DRV_NAME)) {
 		printk ("ne3210.c: Unable to request shared memory at physical address %#lx\n",
 			phys_mem);
 		goto out3;
diff -Nru a/drivers/net/ni52.c b/drivers/net/ni52.c
--- a/drivers/net/ni52.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/ni52.c	Sat May 22 17:40:55 2004
@@ -124,6 +124,8 @@
 
 #include "ni52.h"
 
+#define DRV_NAME "ni52"
+
 #define DEBUG       /* debug on */
 #define SYSBUSVAL 1 /* 8 Bit */
 
@@ -424,7 +426,7 @@
 	dev->mem_start = memstart;
 	dev->mem_end = memend;
 
-	if (!request_region(ioaddr, NI52_TOTAL_SIZE, dev->name))
+	if (!request_region(ioaddr, NI52_TOTAL_SIZE, DRV_NAME))
 		return -EBUSY;
 
 	if( !(inb(ioaddr+NI52_MAGIC1) == NI52_MAGICVAL1) ||
diff -Nru a/drivers/net/ns83820.c b/drivers/net/ns83820.c
--- a/drivers/net/ns83820.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/ns83820.c	Sat May 22 17:40:55 2004
@@ -113,6 +113,8 @@
 #include <asm/uaccess.h>
 #include <asm/system.h>
 
+#define DRV_NAME "ns83820"
+
 /* Global parameters.  See MODULE_PARM near the bottom. */
 static int ihr = 2;
 static int reset_phy = 0;
@@ -1851,7 +1853,7 @@
 		0);
 
 	err = request_irq(pci_dev->irq, ns83820_irq, SA_SHIRQ,
-			  ndev->name, ndev);
+			  DRV_NAME, ndev);
 	if (err) {
 		printk(KERN_INFO "ns83820: unable to register irq %d\n",
 			pci_dev->irq);
diff -Nru a/drivers/net/oaknet.c b/drivers/net/oaknet.c
--- a/drivers/net/oaknet.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/oaknet.c	Sat May 22 17:40:55 2004
@@ -164,7 +164,7 @@
 	ret = -EAGAIN;
 	if (request_irq(dev->irq, ei_interrupt, 0, name, dev)) {
 		printk("%s: unable to request interrupt %d.\n",
-		       dev->name, dev->irq);
+		       name, dev->irq);
 		goto out_region;
 	}
 
diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/r8169.c	Sat May 22 17:40:55 2004
@@ -716,7 +716,7 @@
 		goto err_out_disable;
 	}
 
-	rc = pci_request_regions(pdev, dev->name);
+	rc = pci_request_regions(pdev, MODULENAME);
 	if (rc) {
 		printk(KERN_ERR PFX "%s: Could not request regions.\n", pdev->slot_name);
 		goto err_out_disable;
diff -Nru a/drivers/net/smc-mca.c b/drivers/net/smc-mca.c
--- a/drivers/net/smc-mca.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/smc-mca.c	Sat May 22 17:40:55 2004
@@ -51,6 +51,8 @@
 #include "8390.h"
 #include "smc-mca.h"
 
+#define DRV_NAME "smc-mca"
+
 static int ultramca_open(struct net_device *dev);
 static void ultramca_reset_8390(struct net_device *dev);
 static void ultramca_get_8390_hdr(struct net_device *dev,
@@ -265,7 +267,7 @@
 		goto err_unclaim;
 	}
 
-	if (!request_region(ioaddr, ULTRA_IO_EXTENT, dev->name)) {
+	if (!request_region(ioaddr, ULTRA_IO_EXTENT, DRV_NAME)) {
 		rc = -ENODEV;
 		goto err_unclaim;
 	}
diff -Nru a/drivers/net/smc-ultra.c b/drivers/net/smc-ultra.c
--- a/drivers/net/smc-ultra.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/smc-ultra.c	Sat May 22 17:40:55 2004
@@ -72,6 +72,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "smc-ultra"
+
 /* A zero-terminated list of I/O addresses to be probed. */
 static unsigned int ultra_portlist[] __initdata =
 {0x200, 0x220, 0x240, 0x280, 0x300, 0x340, 0x380, 0};
@@ -217,7 +219,7 @@
 	unsigned char idreg = inb(ioaddr + 7);
 	unsigned char reg4 = inb(ioaddr + 4) & 0x7f;
 
-	if (!request_region(ioaddr, ULTRA_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, ULTRA_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 	/* Check the ID nibble. */
diff -Nru a/drivers/net/smc-ultra32.c b/drivers/net/smc-ultra32.c
--- a/drivers/net/smc-ultra32.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/smc-ultra32.c	Sat May 22 17:40:55 2004
@@ -61,6 +61,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "smc-ultra32"
+
 static int ultra32_probe1(struct net_device *dev, int ioaddr);
 static int ultra32_open(struct net_device *dev);
 static void ultra32_reset_8390(struct net_device *dev);
@@ -163,7 +165,7 @@
 	unsigned char reg4;
 	const char *ifmap[] = {"UTP No Link", "", "UTP/AUI", "UTP/BNC"};
 
-	if (!request_region(ioaddr, ULTRA32_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, ULTRA32_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 	if (inb(ioaddr + ULTRA32_IDPORT) == 0xff ||
diff -Nru a/drivers/net/smc9194.c b/drivers/net/smc9194.c
--- a/drivers/net/smc9194.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/smc9194.c	Sat May 22 17:40:55 2004
@@ -78,6 +78,8 @@
 
 #include "smc9194.h"
 
+#define DRV_NAME "smc9194"
+
 /*------------------------------------------------------------------------
  .
  . Configuration options, for the experienced user to change.
@@ -843,7 +845,7 @@
 	word memory_cfg_register;
 
 	/* Grab the region so that no one else tries to probe our ioports. */
-	if (!request_region(ioaddr, SMC_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, SMC_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
 
 	dev->irq = irq;
@@ -1001,9 +1003,9 @@
 	memset(dev->priv, 0, sizeof(struct smc_local));
 
 	/* Grab the IRQ */
-      	retval = request_irq(dev->irq, &smc_interrupt, 0, dev->name, dev);
+      	retval = request_irq(dev->irq, &smc_interrupt, 0, DRV_NAME, dev);
       	if (retval) {
-		printk("%s: unable to get IRQ %d (irqval=%d).\n", dev->name,
+		printk("%s: unable to get IRQ %d (irqval=%d).\n", DRV_NAME,
 			dev->irq, retval);
   	  	goto err_out;
       	}
diff -Nru a/drivers/net/starfire.c b/drivers/net/starfire.c
--- a/drivers/net/starfire.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/starfire.c	Sat May 22 17:40:55 2004
@@ -880,7 +880,7 @@
 
 	irq = pdev->irq;
 
-	if (pci_request_regions (pdev, dev->name)) {
+	if (pci_request_regions (pdev, DRV_NAME)) {
 		printk(KERN_ERR DRV_NAME " %d: cannot reserve PCI resources, aborting\n", card_idx);
 		goto err_out_free_netdev;
 	}
diff -Nru a/drivers/net/stnic.c b/drivers/net/stnic.c
--- a/drivers/net/stnic.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/stnic.c	Sat May 22 17:40:55 2004
@@ -28,6 +28,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "stnic"
+
 #define byte	unsigned char
 #define half	unsigned short
 #define word	unsigned int
@@ -130,7 +132,7 @@
 
   /* Snarf the interrupt now.  There's no point in waiting since we cannot
      share and the board will usually be enabled. */
-  err = request_irq (dev->irq, ei_interrupt, 0, dev->name, dev);
+  err = request_irq (dev->irq, ei_interrupt, 0, DRV_NAME, dev);
   if (err)  {
       printk (KERN_EMERG " unable to get IRQ %d.\n", dev->irq);
       free_netdev(dev);
diff -Nru a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
--- a/drivers/net/sun3_82586.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/sun3_82586.c	Sat May 22 17:40:55 2004
@@ -53,6 +53,8 @@
 
 #include "sun3_82586.h"
 
+#define DRV_NAME "sun3_82586"
+
 #define DEBUG       /* debug on */
 #define SYSBUSVAL 0 /* 16 Bit */
 #define SUN3_82586_TOTAL_SIZE	PAGE_SIZE
@@ -336,7 +338,7 @@
 {
 	int i, size, retval;
 
-	if (!request_region(ioaddr, SUN3_82586_TOTAL_SIZE, dev->name))
+	if (!request_region(ioaddr, SUN3_82586_TOTAL_SIZE, DRV_NAME))
 		return -EBUSY;
 
 	/* copy in the ethernet address from the prom */
diff -Nru a/drivers/net/sungem.c b/drivers/net/sungem.c
--- a/drivers/net/sungem.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/sungem.c	Sat May 22 17:40:55 2004
@@ -2717,7 +2717,7 @@
 
 	gp = dev->priv;
 
-	err = pci_request_regions(pdev, dev->name);
+	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
 		printk(KERN_ERR PFX "Cannot obtain PCI resources, "
 		       "aborting.\n");
diff -Nru a/drivers/net/sunhme.c b/drivers/net/sunhme.c
--- a/drivers/net/sunhme.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/sunhme.c	Sat May 22 17:40:55 2004
@@ -68,6 +68,8 @@
 #include "sunhme.h"
 
 
+#define DRV_NAME "sunhme"
+
 static int macaddr[6];
 
 /* accept MAC address of the form macaddr=0x08,0x00,0x20,0x30,0x40,0x50 */
@@ -3085,7 +3087,7 @@
 		printk(KERN_ERR "happymeal(PCI): Cannot find proper PCI device base address.\n");
 		goto err_out_clear_quattro;
 	}
-	if (pci_request_regions(pdev, dev->name)) {
+	if (pci_request_regions(pdev, DRV_NAME)) {
 		printk(KERN_ERR "happymeal(PCI): Cannot obtain PCI resources, "
 		       "aborting.\n");
 		goto err_out_clear_quattro;
diff -Nru a/drivers/net/wd.c b/drivers/net/wd.c
--- a/drivers/net/wd.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/wd.c	Sat May 22 17:40:55 2004
@@ -43,6 +43,8 @@
 
 #include "8390.h"
 
+#define DRV_NAME "wd"
+
 /* A zero-terminated list of I/O addresses to be probed. */
 static unsigned int wd_portlist[] __initdata =
 {0x300, 0x280, 0x380, 0x240, 0};
@@ -302,7 +304,7 @@
 
 	/* Snarf the interrupt now.  There's no point in waiting since we cannot
 	   share and the board will usually be enabled. */
-	i = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);
+	i = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
 	if (i) {
 		printk (" unable to get IRQ %d.\n", dev->irq);
 		return i;
diff -Nru a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
--- a/drivers/net/yellowfin.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/yellowfin.c	Sat May 22 17:40:55 2004
@@ -448,7 +448,7 @@
 
 	np = dev->priv;
 
-	if (pci_request_regions(pdev, dev->name))
+	if (pci_request_regions(pdev, DRV_NAME))
 		goto err_out_free_netdev;
 
 	pci_set_master (pdev);
diff -Nru a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
--- a/drivers/net/zorro8390.c	Sat May 22 17:40:55 2004
+++ b/drivers/net/zorro8390.c	Sat May 22 17:40:55 2004
@@ -36,6 +36,8 @@
 #include "8390.h"
 
 
+#define DRV_NAME	"zorro8390"
+
 #define NE_BASE		(dev->base_addr)
 #define NE_CMD		(0x00*2)
 #define NE_DATAPORT	(0x10*2)	/* NatSemi-defined port window offset. */
@@ -115,7 +117,7 @@
     if (!dev)
 	return -ENOMEM;
     SET_MODULE_OWNER(dev);
-    if (!request_mem_region(ioaddr, NE_IO_EXTENT*2, dev->name)) {
+    if (!request_mem_region(ioaddr, NE_IO_EXTENT*2, DRV_NAME)) {
 	free_netdev(dev);
 	return -EBUSY;
     }
@@ -198,7 +200,7 @@
     dev->irq = IRQ_AMIGA_PORTS;
 
     /* Install the Interrupt handler */
-    i = request_irq(IRQ_AMIGA_PORTS, ei_interrupt, SA_SHIRQ, dev->name, dev);
+    i = request_irq(IRQ_AMIGA_PORTS, ei_interrupt, SA_SHIRQ, DRV_NAME, dev);
     if (i) return i;
 
     for(i = 0; i < ETHER_ADDR_LEN; i++) {

--UlVJffcvxoiEqYs2--
