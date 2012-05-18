From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/5] cirrus: cs89x0: Code style neatening
Date: Fri, 18 May 2012 15:56:27 -0700
Message-ID: <b3a9dd523d4055c539f468f641e45686b8c8778e.1337381533.git.joe@perches.com>
References: <cover.1337381533.git.joe@perches.com>
Cc: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1337381533.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neaten the comments and reflow the code without
changing anything other than whitespace.

git diff -w shows just comment neatening and a few
line removals.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |  734 +++++++++++++++-------------------
 1 files changed, 323 insertions(+), 411 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 1d59030..41c8ac9 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -1,105 +1,27 @@
 /* cs89x0.c: A Crystal Semiconductor (Now Cirrus Logic) CS89[02]0
- *  driver for linux.
+ *           driver for linux.
+ * Written 1996 by Russell Nelson, with reference to skeleton.c
+ * written 1993-1994 by Donald Becker.
+ *
+ * This software may be used and distributed according to the terms
+ * of the GNU General Public License, incorporated herein by reference.
+ *
+ * The author may be reached at nelson@crynwr.com, Crynwr
+ * Software, 521 Pleasant Valley Rd., Potsdam, NY 13676
+ *
+ * Other contributors:
+ * Mike Cruse        : mcruse@cti-ltd.com
+ * Russ Nelson
+ * Melody Lee        : ethernet@crystal.cirrus.com
+ * Alan Cox
+ * Andrew Morton
+ * Oskar Schirmer    : oskar@scara.com
+ * Deepak Saxena     : dsaxena@plexity.net
+ * Dmitry Pervushin  : dpervushin@ru.mvista.com
+ * Deepak Saxena     : dsaxena@plexity.net
+ * Domenico Andreoli : cavokz@gmail.com
  */
 
-/*
-	Written 1996 by Russell Nelson, with reference to skeleton.c
-	written 1993-1994 by Donald Becker.
-
-	This software may be used and distributed according to the terms
-	of the GNU General Public License, incorporated herein by reference.
-
-        The author may be reached at nelson@crynwr.com, Crynwr
-        Software, 521 Pleasant Valley Rd., Potsdam, NY 13676
-
-  Changelog:
-
-  Mike Cruse        : mcruse@cti-ltd.com
-                    : Changes for Linux 2.0 compatibility.
-                    : Added dev_id parameter in net_interrupt(),
-                    : request_irq() and free_irq(). Just NULL for now.
-
-  Mike Cruse        : Added MOD_INC_USE_COUNT and MOD_DEC_USE_COUNT macros
-                    : in net_open() and net_close() so kerneld would know
-                    : that the module is in use and wouldn't eject the
-                    : driver prematurely.
-
-  Mike Cruse        : Rewrote init_module() and cleanup_module using 8390.c
-                    : as an example. Disabled autoprobing in init_module(),
-                    : not a good thing to do to other devices while Linux
-                    : is running from all accounts.
-
-  Russ Nelson       : Jul 13 1998.  Added RxOnly DMA support.
-
-  Melody Lee        : Aug 10 1999.  Changes for Linux 2.2.5 compatibility.
-                    : email: ethernet@crystal.cirrus.com
-
-  Alan Cox          : Removed 1.2 support, added 2.1 extra counters.
-
-  Andrew Morton     : Kernel 2.3.48
-                    : Handle kmalloc() failures
-                    : Other resource allocation fixes
-                    : Add SMP locks
-                    : Integrate Russ Nelson's ALLOW_DMA functionality back in.
-                    : If ALLOW_DMA is true, make DMA runtime selectable
-                    : Folded in changes from Cirrus (Melody Lee
-                    : <klee@crystal.cirrus.com>)
-                    : Don't call netif_wake_queue() in net_send_packet()
-                    : Fixed an out-of-mem bug in dma_rx()
-                    : Updated Documentation/networking/cs89x0.txt
-
-  Andrew Morton     : Kernel 2.3.99-pre1
-                    : Use skb_reserve to longword align IP header (two places)
-                    : Remove a delay loop from dma_rx()
-                    : Replace '100' with HZ
-                    : Clean up a couple of skb API abuses
-                    : Added 'cs89x0_dma=N' kernel boot option
-                    : Correctly initialise lp->lock in non-module compile
-
-  Andrew Morton     : Kernel 2.3.99-pre4-1
-                    : MOD_INC/DEC race fix (see
-                    : http://www.uwsg.indiana.edu/hypermail/linux/kernel/0003.3/1532.html)
-
-  Andrew Morton     : Kernel 2.4.0-test7-pre2
-                    : Enhanced EEPROM support to cover more devices,
-                    :   abstracted IRQ mapping to support CONFIG_ARCH_CLPS7500 arch
-                    :   (Jason Gunthorpe <jgg@ualberta.ca>)
-
-  Andrew Morton     : Kernel 2.4.0-test11-pre4
-                    : Use dev->name in request_*() (Andrey Panin)
-                    : Fix an error-path memleak in init_module()
-                    : Preserve return value from request_irq()
-                    : Fix type of `media' module parm (Keith Owens)
-                    : Use SET_MODULE_OWNER()
-                    : Tidied up strange request_irq() abuse in net_open().
-
-  Andrew Morton     : Kernel 2.4.3-pre1
-                    : Request correct number of pages for DMA (Hugh Dickens)
-                    : Select PP_ChipID _after_ unregister_netdev in cleanup_module()
-                    :  because unregister_netdev() calls get_stats.
-                    : Make `version[]' __initdata
-                    : Uninlined the read/write reg/word functions.
-
-  Oskar Schirmer    : oskar@scara.com
-                    : HiCO.SH4 (superh) support added (irq#1, cs89x0_media=)
-
-  Deepak Saxena     : dsaxena@plexity.net
-                    : Intel IXDP2x01 (XScale ixp2x00 NPU) platform support
-
-  Dmitry Pervushin  : dpervushin@ru.mvista.com
-                    : PNX010X platform support
-
-  Deepak Saxena     : dsaxena@plexity.net
-                    : Intel IXDP2351 platform support
-
-  Dmitry Pervushin  : dpervushin@ru.mvista.com
-                    : PNX010X platform support
-
-  Domenico Andreoli : cavokz@gmail.com
-                    : QQ2440 platform support
-
-*/
-
 
 /*
  * Set this to zero to disable DMA code
@@ -119,14 +41,10 @@
  */
 #define DEBUGGING	1
 
-/*
-  Sources:
-
-	Crynwr packet driver epktisa.
-
-	Crystal Semiconductor data sheets.
-
-*/
+/* Sources:
+ *	Crynwr packet driver epktisa.
+ *	Crystal Semiconductor data sheets.
+ */
 
 #include <linux/module.h>
 #include <linux/printk.h>
@@ -158,21 +76,23 @@
 #include "cs89x0.h"
 
 static char version[] __initdata =
-"cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Morton\n";
+	"cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Morton\n";
 
 #define DRV_NAME "cs89x0"
 
 /* First, a few definitions that the brave might change.
-   A zero-terminated list of I/O addresses to be probed. Some special flags..
-      Addr & 1 = Read back the address port, look for signature and reset
-                 the page window before probing
-      Addr & 3 = Reset the page window and probe
-   The CLPS eval board has the Cirrus chip at 0x80090300, in ARM IO space,
-   but it is possible that a Cirrus board could be plugged into the ISA
-   slots. */
+ * A zero-terminated list of I/O addresses to be probed. Some special flags..
+ * Addr & 1 = Read back the address port, look for signature and reset
+ * the page window before probing
+ * Addr & 3 = Reset the page window and probe
+ * The CLPS eval board has the Cirrus chip at 0x80090300, in ARM IO space,
+ * but it is possible that a Cirrus board could be plugged into the ISA
+ * slots.
+ */
 /* The cs8900 has 4 IRQ pins, software selectable. cs8900_irq_map maps
-   them to system IRQ numbers. This mapping is card specific and is set to
-   the configuration of the Cirrus Eval board for this chip. */
+ * them to system IRQ numbers. This mapping is card specific and is set to
+ * the configuration of the Cirrus Eval board for this chip.
+ */
 #if defined(CONFIG_MACH_IXDP2351)
 #define CS89x0_NONISA_IRQ
 static unsigned int netcard_portlist[] __used __initdata = {IXDP2351_VIRT_CS8900_BASE, 0};
@@ -184,8 +104,8 @@ static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
 #else
 #ifndef CONFIG_CS89x0_PLATFORM
 static unsigned int netcard_portlist[] __used __initdata =
-   { 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
-static unsigned int cs8900_irq_map[] = {10,11,12,5};
+{ 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
+static unsigned int cs8900_irq_map[] = {10, 11, 12, 5};
 #endif
 #endif
 
@@ -268,7 +188,7 @@ static int g_cs89x0_dma;
 
 static int __init dma_fn(char *str)
 {
-	g_cs89x0_dma = simple_strtol(str,NULL,0);
+	g_cs89x0_dma = simple_strtol(str, NULL, 0);
 	return 1;
 }
 
@@ -362,10 +282,11 @@ static int __init
 wait_eeprom_ready(struct net_device *dev)
 {
 	int timeout = jiffies;
-	/* check to see if the EEPROM is ready, a timeout is used -
-	   just in case EEPROM is ready when SI_BUSY in the
-	   PP_SelfST is clear */
-	while(readreg(dev, PP_SelfST) & SI_BUSY)
+	/* check to see if the EEPROM is ready,
+	 * a timeout is used just in case EEPROM is ready when
+	 * SI_BUSY in the PP_SelfST is clear
+	 */
+	while (readreg(dev, PP_SelfST) & SI_BUSY)
 		if (jiffies - timeout >= 40)
 			return -1;
 	return 0;
@@ -376,7 +297,7 @@ get_eeprom_data(struct net_device *dev, int off, int len, int *buffer)
 {
 	int i;
 
-	if (net_debug > 3) printk("EEPROM data from %x for %x:\n",off,len);
+	if (net_debug > 3) printk("EEPROM data from %x for %x:\n", off, len);
 	for (i = 0; i < len; i++) {
 		if (wait_eeprom_ready(dev) < 0) return -1;
 		/* Now send the EEPROM read command and EEPROM location to read */
@@ -386,7 +307,7 @@ get_eeprom_data(struct net_device *dev, int off, int len, int *buffer)
 		if (net_debug > 3) printk("%04x ", buffer[i]);
 	}
 	if (net_debug > 3) printk("\n");
-        return 0;
+	return 0;
 }
 
 static int  __init
@@ -420,10 +341,10 @@ static const struct net_device_ops net_ops = {
 	.ndo_open		= net_open,
 	.ndo_stop		= net_close,
 	.ndo_tx_timeout		= net_timeout,
-	.ndo_start_xmit 	= net_send_packet,
+	.ndo_start_xmit		= net_send_packet,
 	.ndo_get_stats		= net_get_stats,
 	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_set_mac_address 	= set_mac_address,
+	.ndo_set_mac_address	= set_mac_address,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= net_poll_controller,
 #endif
@@ -431,12 +352,12 @@ static const struct net_device_ops net_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-/* This is the real probe routine.  Linux has a history of friendly device
-   probes on the ISA bus.  A good device probes avoids doing writes, and
-   verifies that the correct device exists and functions.
-   Return 0 on success.
+/* This is the real probe routine.
+ * Linux has a history of friendly device probes on the ISA bus.
+ * A good device probes avoids doing writes, and
+ * verifies that the correct device exists and functions.
+ * Return 0 on success.
  */
-
 static int __init
 cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 {
@@ -462,7 +383,7 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 #endif
 		lp->force = g_cs89x0_media__force;
 #endif
-        }
+	}
 
 	printk(KERN_DEBUG "PP_addr at %p[%x]: 0x%x\n",
 	       ioaddr, ADD_PORT, ioread16(ioaddr + ADD_PORT));
@@ -471,9 +392,9 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 	tmp = ioread16(ioaddr + DATA_PORT);
 	if (tmp != CHIP_EISA_ID_SIG) {
 		printk(KERN_DEBUG "%s: incorrect signature at %p[%x]: 0x%x!="
-			CHIP_EISA_ID_SIG_STR "\n",
-			dev->name, ioaddr, DATA_PORT, tmp);
-  		retval = -ENODEV;
+		       CHIP_EISA_ID_SIG_STR "\n",
+		       dev->name, ioaddr, DATA_PORT, tmp);
+		retval = -ENODEV;
 		goto out1;
 	}
 
@@ -481,11 +402,11 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 
 	/* get the chip type */
 	rev_type = readreg(dev, PRODUCT_ID_ADD);
-	lp->chip_type = rev_type &~ REVISON_BITS;
+	lp->chip_type = rev_type & ~REVISON_BITS;
 	lp->chip_revision = ((rev_type & REVISON_BITS) >> 8) + 'A';
 
 	/* Check the chip type and revision in order to set the correct send command
-	CS8920 revision C and CS8900 revision F can use the faster send. */
+	   CS8920 revision C and CS8900 revision F can use the faster send. */
 	lp->send_cmd = TX_AFTER_381;
 	if (lp->chip_type == CS8900 && lp->chip_revision >= 'F')
 		lp->send_cmd = TX_NOW;
@@ -497,45 +418,46 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 
 	printk(KERN_INFO "%s: cs89%c0%s rev %c found at %p ",
 	       dev->name,
-	       lp->chip_type==CS8900?'0':'2',
-	       lp->chip_type==CS8920M?"M":"",
+	       lp->chip_type == CS8900  ? '0' : '2',
+	       lp->chip_type == CS8920M ? "M" : "",
 	       lp->chip_revision,
 	       lp->virt_addr);
 
 	reset_chip(dev);
 
-        /* Here we read the current configuration of the chip. If there
-	   is no Extended EEPROM then the idea is to not disturb the chip
-	   configuration, it should have been correctly setup by automatic
-	   EEPROM read on reset. So, if the chip says it read the EEPROM
-	   the driver will always do *something* instead of complain that
-	   adapter_cnf is 0. */
-
-
-        if ((readreg(dev, PP_SelfST) & (EEPROM_OK | EEPROM_PRESENT)) ==
-	      (EEPROM_OK|EEPROM_PRESENT)) {
-	        /* Load the MAC. */
-		for (i=0; i < ETH_ALEN/2; i++) {
-	                unsigned int Addr;
-			Addr = readreg(dev, PP_IA+i*2);
-		        dev->dev_addr[i*2] = Addr & 0xFF;
-		        dev->dev_addr[i*2+1] = Addr >> 8;
+	/* Here we read the current configuration of the chip.
+	 * If there is no Extended EEPROM then the idea is to not disturb
+	 * the chip configuration, it should have been correctly setup by
+	 * automatic EEPROM read on reset. So, if the chip says it read
+	 * the EEPROM the driver will always do *something* instead of
+	 * complain that adapter_cnf is 0.
+	 */
+
+	if ((readreg(dev, PP_SelfST) & (EEPROM_OK | EEPROM_PRESENT)) ==
+	    (EEPROM_OK|EEPROM_PRESENT)) {
+		/* Load the MAC. */
+		for (i = 0; i < ETH_ALEN / 2; i++) {
+			unsigned int Addr;
+			Addr = readreg(dev, PP_IA + i * 2);
+			dev->dev_addr[i * 2] = Addr & 0xFF;
+			dev->dev_addr[i * 2 + 1] = Addr >> 8;
 		}
 
-	   	/* Load the Adapter Configuration.
-		   Note:  Barring any more specific information from some
-		   other source (ie EEPROM+Schematics), we would not know
-		   how to operate a 10Base2 interface on the AUI port.
-		   However, since we  do read the status of HCB1 and use
-		   settings that always result in calls to control_dc_dc(dev,0)
-		   a BNC interface should work if the enable pin
-		   (dc/dc converter) is on HCB1. It will be called AUI
-		   however. */
+		/* Load the Adapter Configuration.
+		 * Note:  Barring any more specific information from some
+		 * other source (ie EEPROM+Schematics), we would not know
+		 * how to operate a 10Base2 interface on the AUI port.
+		 * However, since we  do read the status of HCB1 and use
+		 * settings that always result in calls to control_dc_dc(dev,0)
+		 * a BNC interface should work if the enable pin
+		 * (dc/dc converter) is on HCB1.
+		 * It will be called AUI however.
+		 */
 
 		lp->adapter_cnf = 0;
 		i = readreg(dev, PP_LineCTL);
 		/* Preserve the setting of the HCB1 pin. */
-		if ((i & (HCB1 | HCB1_ENBL)) ==  (HCB1 | HCB1_ENBL))
+		if ((i & (HCB1 | HCB1_ENBL)) == (HCB1 | HCB1_ENBL))
 			lp->adapter_cnf |= A_CNF_DC_DC_POLARITY;
 		/* Save the sqelch bit */
 		if ((i & LOW_RX_SQUELCH) == LOW_RX_SQUELCH)
@@ -549,92 +471,94 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 		/* Check if the card is in Auto mode. */
 		if ((i & (AUI_ONLY | AUTO_AUI_10BASET)) == AUTO_AUI_10BASET)
 			lp->adapter_cnf |=  A_CNF_AUI | A_CNF_10B_T |
-			A_CNF_MEDIA_AUI | A_CNF_MEDIA_10B_T | A_CNF_MEDIA_AUTO;
+				A_CNF_MEDIA_AUI | A_CNF_MEDIA_10B_T | A_CNF_MEDIA_AUTO;
 
 		if (net_debug > 1)
 			printk(KERN_INFO "%s: PP_LineCTL=0x%x, adapter_cnf=0x%x\n",
-					dev->name, i, lp->adapter_cnf);
+			       dev->name, i, lp->adapter_cnf);
 
 		/* IRQ. Other chips already probe, see below. */
 		if (lp->chip_type == CS8900)
 			lp->isa_config = readreg(dev, PP_CS8900_ISAINT) & INT_NO_MASK;
 
-		printk( "[Cirrus EEPROM] ");
+		printk("[Cirrus EEPROM] ");
 	}
 
-        printk("\n");
+	printk("\n");
 
 	/* First check to see if an EEPROM is attached. */
 
 	if ((readreg(dev, PP_SelfST) & EEPROM_PRESENT) == 0)
 		printk(KERN_WARNING "cs89x0: No EEPROM, relying on command line....\n");
-	else if (get_eeprom_data(dev, START_EEPROM_DATA,CHKSUM_LEN,eeprom_buff) < 0) {
+	else if (get_eeprom_data(dev, START_EEPROM_DATA, CHKSUM_LEN, eeprom_buff) < 0) {
 		printk(KERN_WARNING "\ncs89x0: EEPROM read failed, relying on command line.\n");
-        } else if (get_eeprom_cksum(START_EEPROM_DATA,CHKSUM_LEN,eeprom_buff) < 0) {
+	} else if (get_eeprom_cksum(START_EEPROM_DATA, CHKSUM_LEN, eeprom_buff) < 0) {
 		/* Check if the chip was able to read its own configuration starting
 		   at 0 in the EEPROM*/
 		if ((readreg(dev, PP_SelfST) & (EEPROM_OK | EEPROM_PRESENT)) !=
-		    (EEPROM_OK|EEPROM_PRESENT))
-                	printk(KERN_WARNING "cs89x0: Extended EEPROM checksum bad and no Cirrus EEPROM, relying on command line\n");
+		    (EEPROM_OK | EEPROM_PRESENT))
+			printk(KERN_WARNING "cs89x0: Extended EEPROM checksum bad and no Cirrus EEPROM, relying on command line\n");
 
-        } else {
+	} else {
 		/* This reads an extended EEPROM that is not documented
-		   in the CS8900 datasheet. */
-
-                /* get transmission control word  but keep the autonegotiation bits */
-                if (!lp->auto_neg_cnf) lp->auto_neg_cnf = eeprom_buff[AUTO_NEG_CNF_OFFSET/2];
-                /* Store adapter configuration */
-                if (!lp->adapter_cnf) lp->adapter_cnf = eeprom_buff[ADAPTER_CNF_OFFSET/2];
-                /* Store ISA configuration */
-                lp->isa_config = eeprom_buff[ISA_CNF_OFFSET/2];
-                dev->mem_start = eeprom_buff[PACKET_PAGE_OFFSET/2] << 8;
-
-                /* eeprom_buff has 32-bit ints, so we can't just memcpy it */
-                /* store the initial memory base address */
-                for (i = 0; i < ETH_ALEN/2; i++) {
-                        dev->dev_addr[i*2] = eeprom_buff[i];
-                        dev->dev_addr[i*2+1] = eeprom_buff[i] >> 8;
-                }
+		 * in the CS8900 datasheet.
+		 */
+
+		/* get transmission control word  but keep the autonegotiation bits */
+		if (!lp->auto_neg_cnf) lp->auto_neg_cnf = eeprom_buff[AUTO_NEG_CNF_OFFSET/2];
+		/* Store adapter configuration */
+		if (!lp->adapter_cnf) lp->adapter_cnf = eeprom_buff[ADAPTER_CNF_OFFSET/2];
+		/* Store ISA configuration */
+		lp->isa_config = eeprom_buff[ISA_CNF_OFFSET/2];
+		dev->mem_start = eeprom_buff[PACKET_PAGE_OFFSET/2] << 8;
+
+		/* eeprom_buff has 32-bit ints, so we can't just memcpy it */
+		/* store the initial memory base address */
+		for (i = 0; i < ETH_ALEN / 2; i++) {
+			dev->dev_addr[i * 2] = eeprom_buff[i];
+			dev->dev_addr[i * 2 + 1] = eeprom_buff[i] >> 8;
+		}
 		if (net_debug > 1)
 			printk(KERN_DEBUG "%s: new adapter_cnf: 0x%x\n",
-				dev->name, lp->adapter_cnf);
-        }
+			       dev->name, lp->adapter_cnf);
+	}
 
-        /* allow them to force multiple transceivers.  If they force multiple, autosense */
-        {
+	/* allow them to force multiple transceivers.  If they force multiple, autosense */
+	{
 		int count = 0;
 		if (lp->force & FORCE_RJ45)	{lp->adapter_cnf |= A_CNF_10B_T; count++; }
-		if (lp->force & FORCE_AUI) 	{lp->adapter_cnf |= A_CNF_AUI; count++; }
+		if (lp->force & FORCE_AUI)	{lp->adapter_cnf |= A_CNF_AUI; count++; }
 		if (lp->force & FORCE_BNC)	{lp->adapter_cnf |= A_CNF_10B_2; count++; }
 		if (count > 1)			{lp->adapter_cnf |= A_CNF_MEDIA_AUTO; }
 		else if (lp->force & FORCE_RJ45){lp->adapter_cnf |= A_CNF_MEDIA_10B_T; }
 		else if (lp->force & FORCE_AUI)	{lp->adapter_cnf |= A_CNF_MEDIA_AUI; }
 		else if (lp->force & FORCE_BNC)	{lp->adapter_cnf |= A_CNF_MEDIA_10B_2; }
-        }
+	}
 
 	if (net_debug > 1)
 		printk(KERN_DEBUG "%s: after force 0x%x, adapter_cnf=0x%x\n",
-			dev->name, lp->force, lp->adapter_cnf);
+		       dev->name, lp->force, lp->adapter_cnf);
 
-        /* FIXME: We don't let you set dc-dc polarity or low RX squelch from the command line: add it here */
+	/* FIXME: We don't let you set dc-dc polarity or low RX squelch from the command line: add it here */
 
-        /* FIXME: We don't let you set the IMM bit from the command line: add it to lp->auto_neg_cnf here */
+	/* FIXME: We don't let you set the IMM bit from the command line: add it to lp->auto_neg_cnf here */
 
-        /* FIXME: we don't set the Ethernet address on the command line.  Use
-           ifconfig IFACE hw ether AABBCCDDEEFF */
+	/* FIXME: we don't set the Ethernet address on the command line.  Use
+	 * ifconfig IFACE hw ether AABBCCDDEEFF
+	 */
 
 	printk(KERN_INFO "cs89x0 media %s%s%s",
-	       (lp->adapter_cnf & A_CNF_10B_T)?"RJ-45,":"",
-	       (lp->adapter_cnf & A_CNF_AUI)?"AUI,":"",
-	       (lp->adapter_cnf & A_CNF_10B_2)?"BNC,":"");
+	       (lp->adapter_cnf & A_CNF_10B_T) ? "RJ-45," : "",
+	       (lp->adapter_cnf & A_CNF_AUI) ? "AUI," : "",
+	       (lp->adapter_cnf & A_CNF_10B_2) ? "BNC," : "");
 
 	lp->irq_map = 0xffff;
 
 	/* If this is a CS8900 then no pnp soft */
 	if (lp->chip_type != CS8900 &&
 	    /* Check if the ISA IRQ has been set  */
-		(i = readreg(dev, PP_CS8920_ISAINT) & 0xff,
-		 (i != 0 && i < CS8920_NO_INTS))) {
+	    (i = readreg(dev, PP_CS8920_ISAINT) & 0xff,
+	     (i != 0 && i < CS8920_NO_INTS))) {
 		if (!dev->irq)
 			dev->irq = i;
 	} else {
@@ -642,7 +566,7 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 #ifndef CONFIG_CS89x0_PLATFORM
 		if (lp->chip_type == CS8900) {
 #ifdef CS89x0_NONISA_IRQ
-		        i = cs8900_irq_map[0];
+			i = cs8900_irq_map[0];
 #else
 			/* Translate the IRQ using the IRQ mapping table. */
 			if (i >= ARRAY_SIZE(cs8900_irq_map))
@@ -655,10 +579,10 @@ cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr, int modular)
 			int irq_map_buff[IRQ_MAP_LEN/2];
 
 			if (get_eeprom_data(dev, IRQ_MAP_EEPROM_DATA,
-					    IRQ_MAP_LEN/2,
+					    IRQ_MAP_LEN / 2,
 					    irq_map_buff) >= 0) {
 				if ((irq_map_buff[0] & 0xff) == PNP_IRQ_FRMT)
-					lp->irq_map = (irq_map_buff[0]>>8) | (irq_map_buff[1] << 8);
+					lp->irq_map = (irq_map_buff[0] >> 8) | (irq_map_buff[1] << 8);
 			}
 #endif
 		}
@@ -730,9 +654,10 @@ cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
 	}
 
 	/* if they give us an odd I/O address, then do ONE write to
-	   the address port, to get it back to address zero, where we
-	   expect to find the EISA signature word. An IO with a base of 0x3
-	   will skip the test for the ADD_PORT. */
+	 * the address port, to get it back to address zero, where we
+	 * expect to find the EISA signature word. An IO with a base of 0x3
+	 * will skip the test for the ADD_PORT.
+	 */
 	if (ioport & 1) {
 		if (net_debug > 1)
 			printk(KERN_INFO "%s: odd ioaddr 0x%lx\n",
@@ -742,8 +667,8 @@ cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
 			if ((ioread16(io_mem + ADD_PORT) & ADD_MASK) !=
 			    ADD_SIG) {
 				printk(KERN_ERR "%s: bad signature 0x%x\n",
-					dev->name,
-					ioread16(io_mem + ADD_PORT));
+				       dev->name,
+				       ioread16(io_mem + ADD_PORT));
 				ret = -ENODEV;
 				goto unmap;
 			}
@@ -762,12 +687,12 @@ out:
 
 #ifndef MODULE
 /* Check for a network adaptor of this type, and return '0' iff one exists.
-   If dev->base_addr == 0, probe all likely locations.
-   If dev->base_addr == 1, always return failure.
-   If dev->base_addr == 2, allocate space for the device and return success
-   (detachable devices only).
-   Return 0 on success.
-   */
+ * If dev->base_addr == 0, probe all likely locations.
+ * If dev->base_addr == 1, always return failure.
+ * If dev->base_addr == 2, allocate space for the device and return success
+ * (detachable devices only).
+ * Return 0 on success.
+ */
 
 struct net_device * __init cs89x0_probe(int unit)
 {
@@ -814,7 +739,7 @@ out:
 
 /*********************************
  * This page contains DMA routines
-**********************************/
+ *********************************/
 
 #if ALLOW_DMA
 
@@ -882,7 +807,7 @@ dma_bufcfg(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	if (lp->use_dma)
-		return (lp->isa_config & ANY_ISA_DMA)? RX_DMA_ENBL : 0;
+		return (lp->isa_config & ANY_ISA_DMA) ? RX_DMA_ENBL : 0;
 	else
 		return 0;
 }
@@ -916,8 +841,8 @@ dma_rx(struct net_device *dev)
 	length = bp[2] + (bp[3]<<8);
 	bp += 4;
 	if (net_debug > 5) {
-		printk(	"%s: receiving DMA packet at %lx, status %x, length %x\n",
-			dev->name, (unsigned long)bp, status, length);
+		printk("%s: receiving DMA packet at %lx, status %x, length %x\n",
+		       dev->name, (unsigned long)bp, status, length);
 	}
 	if ((status & RX_OK) == 0) {
 		count_rx_errors(status, dev);
@@ -942,22 +867,22 @@ skip_this_frame:
 
 	if (bp + length > lp->end_dma_buff) {
 		int semi_cnt = lp->end_dma_buff - bp;
-		memcpy(skb_put(skb,semi_cnt), bp, semi_cnt);
-		memcpy(skb_put(skb,length - semi_cnt), lp->dma_buff,
+		memcpy(skb_put(skb, semi_cnt), bp, semi_cnt);
+		memcpy(skb_put(skb, length - semi_cnt), lp->dma_buff,
 		       length - semi_cnt);
 	} else {
-		memcpy(skb_put(skb,length), bp, length);
+		memcpy(skb_put(skb, length), bp, length);
 	}
 	bp += (length + 3) & ~3;
 	if (bp >= lp->end_dma_buff) bp -= lp->dmasize*1024;
 	lp->rx_dma_ptr = bp;
 
 	if (net_debug > 3) {
-		printk(	"%s: received %d byte DMA packet of type %x\n",
-			dev->name, length,
-			(skb->data[ETH_ALEN+ETH_ALEN] << 8) | skb->data[ETH_ALEN+ETH_ALEN+1]);
+		printk("%s: received %d byte DMA packet of type %x\n",
+		       dev->name, length,
+		       (skb->data[ETH_ALEN + ETH_ALEN] << 8) | skb->data[ETH_ALEN + ETH_ALEN + 1]);
 	}
-        skb->protocol=eth_type_trans(skb,dev);
+	skb->protocol = eth_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += length;
@@ -995,7 +920,7 @@ static void __init reset_chip(struct net_device *dev)
 
 	/* Wait until the chip is reset */
 	reset_start_time = jiffies;
-	while( (readreg(dev, PP_SelfST) & INIT_DONE) == 0 && jiffies - reset_start_time < 2)
+	while ((readreg(dev, PP_SelfST) & INIT_DONE) == 0 && jiffies - reset_start_time < 2)
 		;
 #endif /* !CONFIG_MACH_MX31ADS */
 }
@@ -1038,38 +963,38 @@ detect_tp(struct net_device *dev)
 
 	if (net_debug > 1) printk("%s: Attempting TP\n", dev->name);
 
-        /* If connected to another full duplex capable 10-Base-T card the link pulses
-           seem to be lost when the auto detect bit in the LineCTL is set.
-           To overcome this the auto detect bit will be cleared whilst testing the
-           10-Base-T interface.  This would not be necessary for the sparrow chip but
-           is simpler to do it anyway. */
-	writereg(dev, PP_LineCTL, lp->linectl &~ AUI_ONLY);
+	/* If connected to another full duplex capable 10-Base-T card the link pulses
+	   seem to be lost when the auto detect bit in the LineCTL is set.
+	   To overcome this the auto detect bit will be cleared whilst testing the
+	   10-Base-T interface.  This would not be necessary for the sparrow chip but
+	   is simpler to do it anyway. */
+	writereg(dev, PP_LineCTL, lp->linectl & ~AUI_ONLY);
 	control_dc_dc(dev, 0);
 
-        /* Delay for the hardware to work out if the TP cable is present - 150ms */
+	/* Delay for the hardware to work out if the TP cable is present - 150ms */
 	for (timenow = jiffies; jiffies - timenow < 15; )
-                ;
+		;
 	if ((readreg(dev, PP_LineST) & LINK_OK) == 0)
 		return DETECTED_NONE;
 
 	if (lp->chip_type == CS8900) {
-                switch (lp->force & 0xf0) {
+		switch (lp->force & 0xf0) {
 #if 0
-                case FORCE_AUTO:
-			printk("%s: cs8900 doesn't autonegotiate\n",dev->name);
-                        return DETECTED_NONE;
+		case FORCE_AUTO:
+			printk("%s: cs8900 doesn't autonegotiate\n", dev->name);
+			return DETECTED_NONE;
 #endif
-		/* CS8900 doesn't support AUTO, change to HALF*/
-                case FORCE_AUTO:
+			/* CS8900 doesn't support AUTO, change to HALF*/
+		case FORCE_AUTO:
 			lp->force &= ~FORCE_AUTO;
-                        lp->force |= FORCE_HALF;
+			lp->force |= FORCE_HALF;
 			break;
 		case FORCE_HALF:
 			break;
-                case FORCE_FULL:
+		case FORCE_FULL:
 			writereg(dev, PP_TestCTL, readreg(dev, PP_TestCTL) | FDX_8900);
 			break;
-                }
+		}
 		fdx = readreg(dev, PP_TestCTL) & FDX_8900;
 	} else {
 		switch (lp->force & 0xf0) {
@@ -1082,12 +1007,12 @@ detect_tp(struct net_device *dev)
 		case FORCE_FULL:
 			lp->auto_neg_cnf = RE_NEG_NOW | ALLOW_FDX;
 			break;
-                }
+		}
 
 		writereg(dev, PP_AutoNegCTL, lp->auto_neg_cnf & AUTO_NEG_MASK);
 
 		if ((lp->auto_neg_cnf & AUTO_NEG_BITS) == AUTO_NEG_ENABLE) {
-			printk(KERN_INFO "%s: negotiating duplex...\n",dev->name);
+			printk(KERN_INFO "%s: negotiating duplex...\n", dev->name);
 			while (readreg(dev, PP_AutoNegST) & AUTO_NEG_BUSY) {
 				if (jiffies - timenow > 4000) {
 					printk(KERN_ERR "**** Full / half duplex auto-negotiation timed out ****\n");
@@ -1109,15 +1034,15 @@ send_test_pkt(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	char test_packet[] = { 0,0,0,0,0,0, 0,0,0,0,0,0,
-				 0, 46, /* A 46 in network order */
-				 0, 0, /* DSAP=0 & SSAP=0 fields */
-				 0xf3, 0 /* Control (Test Req + P bit set) */ };
+			       0, 46, /* A 46 in network order */
+			       0, 0, /* DSAP=0 & SSAP=0 fields */
+			       0xf3, 0 /* Control (Test Req + P bit set) */ };
 	long timenow = jiffies;
 
 	writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) | SERIAL_TX_ON);
 
-	memcpy(test_packet,          dev->dev_addr, ETH_ALEN);
-	memcpy(test_packet+ETH_ALEN, dev->dev_addr, ETH_ALEN);
+	memcpy(test_packet,            dev->dev_addr, ETH_ALEN);
+	memcpy(test_packet + ETH_ALEN, dev->dev_addr, ETH_ALEN);
 
 	iowrite16(TX_AFTER_ALL, lp->virt_addr + TX_CMD_PORT);
 	iowrite16(ETH_ZLEN, lp->virt_addr + TX_LEN_PORT);
@@ -1135,11 +1060,11 @@ send_test_pkt(struct net_device *dev)
 	if (net_debug > 1) printk("Sending test packet ");
 	/* wait a couple of jiffies for packet to be received */
 	for (timenow = jiffies; jiffies - timenow < 3; )
-                ;
-        if ((readreg(dev, PP_TxEvent) & TX_SEND_OK_BITS) == TX_OK) {
-                if (net_debug > 1) printk("succeeded\n");
-                return 1;
-        }
+		;
+	if ((readreg(dev, PP_TxEvent) & TX_SEND_OK_BITS) == TX_OK) {
+		if (net_debug > 1) printk("succeeded\n");
+		return 1;
+	}
 	if (net_debug > 1) printk("failed\n");
 	return 0;
 }
@@ -1153,7 +1078,7 @@ detect_aui(struct net_device *dev)
 	if (net_debug > 1) printk("%s: Attempting AUI\n", dev->name);
 	control_dc_dc(dev, 0);
 
-	writereg(dev, PP_LineCTL, (lp->linectl &~ AUTO_AUI_10BASET) | AUI_ONLY);
+	writereg(dev, PP_LineCTL, (lp->linectl & ~AUTO_AUI_10BASET) | AUI_ONLY);
 
 	if (send_test_pkt(dev))
 		return DETECTED_AUI;
@@ -1169,7 +1094,7 @@ detect_bnc(struct net_device *dev)
 	if (net_debug > 1) printk("%s: Attempting BNC\n", dev->name);
 	control_dc_dc(dev, 1);
 
-	writereg(dev, PP_LineCTL, (lp->linectl &~ AUTO_AUI_10BASET) | AUI_ONLY);
+	writereg(dev, PP_LineCTL, (lp->linectl & ~AUTO_AUI_10BASET) | AUI_ONLY);
 
 	if (send_test_pkt(dev))
 		return DETECTED_BNC;
@@ -1208,7 +1133,7 @@ write_irq(struct net_device *dev, int chip_type, int irq)
    This routine should set everything up anew at each open, even
    registers that "should" only need to be set once at boot, so that
    there is non-reboot way to recover if something goes wrong.
-   */
+*/
 
 /* AKPM: do we need to do any locking here? */
 
@@ -1224,7 +1149,7 @@ net_open(struct net_device *dev)
 		/* Allow interrupts to be generated by the chip */
 /* Cirrus' release had this: */
 #if 0
-		writereg(dev, PP_BusCTL, readreg(dev, PP_BusCTL)|ENABLE_IRQ );
+		writereg(dev, PP_BusCTL, readreg(dev, PP_BusCTL) | ENABLE_IRQ);
 #endif
 /* And 2.3.47 had this: */
 		writereg(dev, PP_BusCTL, ENABLE_IRQ | MEMORY_ON);
@@ -1252,13 +1177,13 @@ net_open(struct net_device *dev)
 #if !defined(CS89x0_NONISA_IRQ) && !defined(CONFIG_CS89x0_PLATFORM)
 		if (((1 << dev->irq) & lp->irq_map) == 0) {
 			printk(KERN_ERR "%s: IRQ %d is not in our map of allowable IRQs, which is %x\n",
-                               dev->name, dev->irq, lp->irq_map);
+			       dev->name, dev->irq, lp->irq_map);
 			ret = -EAGAIN;
 			goto bad_out;
 		}
 #endif
 /* FIXME: Cirrus' release had this: */
-		writereg(dev, PP_BusCTL, readreg(dev, PP_BusCTL)|ENABLE_IRQ );
+		writereg(dev, PP_BusCTL, readreg(dev, PP_BusCTL)|ENABLE_IRQ);
 /* And 2.3.47 had this: */
 #if 0
 		writereg(dev, PP_BusCTL, ENABLE_IRQ | MEMORY_ON);
@@ -1276,17 +1201,17 @@ net_open(struct net_device *dev)
 		if (lp->isa_config & ANY_ISA_DMA) {
 			unsigned long flags;
 			lp->dma_buff = (unsigned char *)__get_dma_pages(GFP_KERNEL,
-							get_order(lp->dmasize * 1024));
+									get_order(lp->dmasize * 1024));
 
 			if (!lp->dma_buff) {
 				printk(KERN_ERR "%s: cannot get %dK memory for DMA\n", dev->name, lp->dmasize);
 				goto release_irq;
 			}
 			if (net_debug > 1) {
-				printk(	"%s: dma %lx %lx\n",
-					dev->name,
-					(unsigned long)lp->dma_buff,
-					(unsigned long)isa_virt_to_bus(lp->dma_buff));
+				printk("%s: dma %lx %lx\n",
+				       dev->name,
+				       (unsigned long)lp->dma_buff,
+				       (unsigned long)isa_virt_to_bus(lp->dma_buff));
 			}
 			if ((unsigned long) lp->dma_buff >= MAX_DMA_ADDRESS ||
 			    !dma_page_eq(lp->dma_buff, lp->dma_buff+lp->dmasize*1024-1)) {
@@ -1314,64 +1239,64 @@ net_open(struct net_device *dev)
 #endif	/* ALLOW_DMA */
 
 	/* set the Ethernet address */
-	for (i=0; i < ETH_ALEN/2; i++)
-		writereg(dev, PP_IA+i*2, dev->dev_addr[i*2] | (dev->dev_addr[i*2+1] << 8));
+	for (i = 0; i < ETH_ALEN / 2; i++)
+		writereg(dev, PP_IA + i * 2, dev->dev_addr[i * 2] | (dev->dev_addr[i * 2 + 1] << 8));
 
 	/* while we're testing the interface, leave interrupts disabled */
 	writereg(dev, PP_BusCTL, MEMORY_ON);
 
 	/* Set the LineCTL quintuplet based on adapter configuration read from EEPROM */
 	if ((lp->adapter_cnf & A_CNF_EXTND_10B_2) && (lp->adapter_cnf & A_CNF_LOW_RX_SQUELCH))
-                lp->linectl = LOW_RX_SQUELCH;
+		lp->linectl = LOW_RX_SQUELCH;
 	else
-                lp->linectl = 0;
+		lp->linectl = 0;
 
-        /* check to make sure that they have the "right" hardware available */
-	switch(lp->adapter_cnf & A_CNF_MEDIA_TYPE) {
+	/* check to make sure that they have the "right" hardware available */
+	switch (lp->adapter_cnf & A_CNF_MEDIA_TYPE) {
 	case A_CNF_MEDIA_10B_T: result = lp->adapter_cnf & A_CNF_10B_T; break;
 	case A_CNF_MEDIA_AUI:   result = lp->adapter_cnf & A_CNF_AUI; break;
 	case A_CNF_MEDIA_10B_2: result = lp->adapter_cnf & A_CNF_10B_2; break;
-        default: result = lp->adapter_cnf & (A_CNF_10B_T | A_CNF_AUI | A_CNF_10B_2);
-        }
-        if (!result) {
-                printk(KERN_ERR "%s: EEPROM is configured for unavailable media\n", dev->name);
+	default: result = lp->adapter_cnf & (A_CNF_10B_T | A_CNF_AUI | A_CNF_10B_2);
+	}
+	if (!result) {
+		printk(KERN_ERR "%s: EEPROM is configured for unavailable media\n", dev->name);
 release_dma:
 #if ALLOW_DMA
 		free_dma(dev->dma);
 release_irq:
 		release_dma_buff(lp);
 #endif
-                writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) & ~(SERIAL_TX_ON | SERIAL_RX_ON));
-                free_irq(dev->irq, dev);
+		writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) & ~(SERIAL_TX_ON | SERIAL_RX_ON));
+		free_irq(dev->irq, dev);
 		ret = -EAGAIN;
 		goto bad_out;
 	}
 
-        /* set the hardware to the configured choice */
-	switch(lp->adapter_cnf & A_CNF_MEDIA_TYPE) {
+	/* set the hardware to the configured choice */
+	switch (lp->adapter_cnf & A_CNF_MEDIA_TYPE) {
 	case A_CNF_MEDIA_10B_T:
-                result = detect_tp(dev);
-                if (result==DETECTED_NONE) {
-                        printk(KERN_WARNING "%s: 10Base-T (RJ-45) has no cable\n", dev->name);
-                        if (lp->auto_neg_cnf & IMM_BIT) /* check "ignore missing media" bit */
-                                result = DETECTED_RJ45H; /* Yes! I don't care if I see a link pulse */
-                }
+		result = detect_tp(dev);
+		if (result == DETECTED_NONE) {
+			printk(KERN_WARNING "%s: 10Base-T (RJ-45) has no cable\n", dev->name);
+			if (lp->auto_neg_cnf & IMM_BIT) /* check "ignore missing media" bit */
+				result = DETECTED_RJ45H; /* Yes! I don't care if I see a link pulse */
+		}
 		break;
 	case A_CNF_MEDIA_AUI:
-                result = detect_aui(dev);
-                if (result==DETECTED_NONE) {
-                        printk(KERN_WARNING "%s: 10Base-5 (AUI) has no cable\n", dev->name);
-                        if (lp->auto_neg_cnf & IMM_BIT) /* check "ignore missing media" bit */
-                                result = DETECTED_AUI; /* Yes! I don't care if I see a carrrier */
-                }
+		result = detect_aui(dev);
+		if (result == DETECTED_NONE) {
+			printk(KERN_WARNING "%s: 10Base-5 (AUI) has no cable\n", dev->name);
+			if (lp->auto_neg_cnf & IMM_BIT) /* check "ignore missing media" bit */
+				result = DETECTED_AUI; /* Yes! I don't care if I see a carrrier */
+		}
 		break;
 	case A_CNF_MEDIA_10B_2:
-                result = detect_bnc(dev);
-                if (result==DETECTED_NONE) {
-                        printk(KERN_WARNING "%s: 10Base-2 (BNC) has no cable\n", dev->name);
-                        if (lp->auto_neg_cnf & IMM_BIT) /* check "ignore missing media" bit */
-                                result = DETECTED_BNC; /* Yes! I don't care if I can xmit a packet */
-                }
+		result = detect_bnc(dev);
+		if (result == DETECTED_NONE) {
+			printk(KERN_WARNING "%s: 10Base-2 (BNC) has no cable\n", dev->name);
+			if (lp->auto_neg_cnf & IMM_BIT) /* check "ignore missing media" bit */
+				result = DETECTED_BNC; /* Yes! I don't care if I can xmit a packet */
+		}
 		break;
 	case A_CNF_MEDIA_AUTO:
 		writereg(dev, PP_LineCTL, lp->linectl | AUTO_AUI_10BASET);
@@ -1387,7 +1312,7 @@ release_irq:
 		printk(KERN_ERR "%s: no media detected\n", dev->name);
 		goto release_dma;
 	}
-	switch(result) {
+	switch (result) {
 	case DETECTED_NONE:
 		printk(KERN_ERR "%s: no network cable attached to configured media\n", dev->name);
 		goto release_dma;
@@ -1422,22 +1347,22 @@ release_irq:
 	writereg(dev, PP_RxCFG, lp->curr_rx_cfg);
 
 	writereg(dev, PP_TxCFG, TX_LOST_CRS_ENBL | TX_SQE_ERROR_ENBL | TX_OK_ENBL |
-		TX_LATE_COL_ENBL | TX_JBR_ENBL | TX_ANY_COL_ENBL | TX_16_COL_ENBL);
+		 TX_LATE_COL_ENBL | TX_JBR_ENBL | TX_ANY_COL_ENBL | TX_16_COL_ENBL);
 
 	writereg(dev, PP_BufCFG, READY_FOR_TX_ENBL | RX_MISS_COUNT_OVRFLOW_ENBL |
 #if ALLOW_DMA
-		dma_bufcfg(dev) |
+		 dma_bufcfg(dev) |
 #endif
-		TX_COL_COUNT_OVRFLOW_ENBL | TX_UNDERRUN_ENBL);
+		 TX_COL_COUNT_OVRFLOW_ENBL | TX_UNDERRUN_ENBL);
 
 	/* now that we've got our act together, enable everything */
 	writereg(dev, PP_BusCTL, ENABLE_IRQ
-		 | (dev->mem_start?MEMORY_ON : 0) /* turn memory on */
+		 | (dev->mem_start ? MEMORY_ON : 0) /* turn memory on */
 #if ALLOW_DMA
 		 | dma_busctl(dev)
 #endif
-                 );
-        netif_start_queue(dev);
+		);
+	netif_start_queue(dev);
 	if (net_debug > 1)
 		printk("cs89x0: net_open() succeeded\n");
 	return 0;
@@ -1450,25 +1375,25 @@ static void net_timeout(struct net_device *dev)
 	/* If we get here, some higher level has decided we are broken.
 	   There should really be a "kick me" function call instead. */
 	if (net_debug > 0) printk("%s: transmit timed out, %s?\n", dev->name,
-		   tx_done(dev) ? "IRQ conflict ?" : "network cable problem");
+				  tx_done(dev) ? "IRQ conflict ?" : "network cable problem");
 	/* Try to restart the adaptor. */
 	netif_wake_queue(dev);
 }
 
-static netdev_tx_t net_send_packet(struct sk_buff *skb,struct net_device *dev)
+static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	if (net_debug > 3) {
 		printk("%s: sent %d byte packet of type %x\n",
-			dev->name, skb->len,
-			(skb->data[ETH_ALEN+ETH_ALEN] << 8) | skb->data[ETH_ALEN+ETH_ALEN+1]);
+		       dev->name, skb->len,
+		       (skb->data[ETH_ALEN + ETH_ALEN] << 8) | skb->data[ETH_ALEN + ETH_ALEN + 1]);
 	}
 
 	/* keep the upload from being interrupted, since we
-                  ask the chip to start transmitting before the
-                  whole packet has been completely uploaded. */
+	   ask the chip to start transmitting before the
+	   whole packet has been completely uploaded. */
 
 	spin_lock_irqsave(&lp->lock, flags);
 	netif_stop_queue(dev);
@@ -1479,8 +1404,7 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb,struct net_device *dev)
 
 	/* Test to see if the chip has allocated memory for the packet */
 	if ((readreg(dev, PP_BusST) & READY_FOR_TX_NOW) == 0) {
-		/*
-		 * Gasp!  It hasn't.  But that shouldn't happen since
+		/* Gasp!  It hasn't.  But that shouldn't happen since
 		 * we're waiting for TxOk, so return 1 and requeue this packet.
 		 */
 
@@ -1492,10 +1416,9 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb,struct net_device *dev)
 	writewords(lp, TX_FRAME_PORT, skb->data, (skb->len+1) >> 1);
 	spin_unlock_irqrestore(&lp->lock, flags);
 	dev->stats.tx_bytes += skb->len;
-	dev_kfree_skb (skb);
+	dev_kfree_skb(skb);
 
-	/*
-	 * We DO NOT call netif_wake_queue() here.
+	/* We DO NOT call netif_wake_queue() here.
 	 * We also DO NOT call netif_start_queue().
 	 *
 	 * Either of these would cause another bottom half run through
@@ -1509,28 +1432,30 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb,struct net_device *dev)
 }
 
 /* The typical workload of the driver:
-   Handle the network interface interrupts. */
+ * Handle the network interface interrupts.
+ */
 
 static irqreturn_t net_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct net_local *lp;
 	int status;
- 	int handled = 0;
+	int handled = 0;
 
 	lp = netdev_priv(dev);
 
 	/* we MUST read all the events out of the ISQ, otherwise we'll never
-           get interrupted again.  As a consequence, we can't have any limit
-           on the number of times we loop in the interrupt handler.  The
-           hardware guarantees that eventually we'll run out of events.  Of
-           course, if you're on a slow machine, and packets are arriving
-           faster than you can read them off, you're screwed.  Hasta la
-           vista, baby!  */
+	 * get interrupted again.  As a consequence, we can't have any limit
+	 * on the number of times we loop in the interrupt handler.  The
+	 * hardware guarantees that eventually we'll run out of events.  Of
+	 * course, if you're on a slow machine, and packets are arriving
+	 * faster than you can read them off, you're screwed.  Hasta la
+	 * vista, baby!
+	 */
 	while ((status = ioread16(lp->virt_addr + ISQ_PORT))) {
 		if (net_debug > 4)printk("%s: event=%04x\n", dev->name, status);
 		handled = 1;
-		switch(status & ISQ_EVENT_MASK) {
+		switch (status & ISQ_EVENT_MASK) {
 		case ISQ_RECEIVER_EVENT:
 			/* Got a packet(s). */
 			net_rx(dev);
@@ -1538,11 +1463,11 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 		case ISQ_TRANSMITTER_EVENT:
 			dev->stats.tx_packets++;
 			netif_wake_queue(dev);	/* Inform upper layers. */
-			if ((status & (	TX_OK |
-					TX_LOST_CRS |
-					TX_SQE_ERROR |
-					TX_LATE_COL |
-					TX_16_COL)) != TX_OK) {
+			if ((status & (TX_OK |
+				       TX_LOST_CRS |
+				       TX_SQE_ERROR |
+				       TX_LATE_COL |
+				       TX_16_COL)) != TX_OK) {
 				if ((status & TX_OK) == 0)
 					dev->stats.tx_errors++;
 				if (status & TX_LOST_CRS)
@@ -1558,31 +1483,33 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 		case ISQ_BUFFER_EVENT:
 			if (status & READY_FOR_TX) {
 				/* we tried to transmit a packet earlier,
-                                   but inexplicably ran out of buffers.
-                                   That shouldn't happen since we only ever
-                                   load one packet.  Shrug.  Do the right
-                                   thing anyway. */
+				 * but inexplicably ran out of buffers.
+				 * That shouldn't happen since we only ever
+				 * load one packet.  Shrug.  Do the right
+				 * thing anyway.
+				 */
 				netif_wake_queue(dev);	/* Inform upper layers. */
 			}
 			if (status & TX_UNDERRUN) {
 				if (net_debug > 0) printk("%s: transmit underrun\n", dev->name);
-                                lp->send_underrun++;
-                                if (lp->send_underrun == 3) lp->send_cmd = TX_AFTER_381;
-                                else if (lp->send_underrun == 6) lp->send_cmd = TX_AFTER_ALL;
+				lp->send_underrun++;
+				if (lp->send_underrun == 3) lp->send_cmd = TX_AFTER_381;
+				else if (lp->send_underrun == 6) lp->send_cmd = TX_AFTER_ALL;
 				/* transmit cycle is done, although
-				   frame wasn't transmitted - this
-				   avoids having to wait for the upper
-				   layers to timeout on us, in the
-				   event of a tx underrun */
+				 * frame wasn't transmitted - this
+				 * avoids having to wait for the upper
+				 * layers to timeout on us, in the
+				 * event of a tx underrun
+				 */
 				netif_wake_queue(dev);	/* Inform upper layers. */
-                        }
+			}
 #if ALLOW_DMA
 			if (lp->use_dma && (status & RX_DMA)) {
 				int count = readreg(dev, PP_DmaFrameCnt);
-				while(count) {
+				while (count) {
 					if (net_debug > 5)
 						printk("%s: receiving %d DMA frames\n", dev->name, count);
-					if (net_debug > 2 && count >1)
+					if (net_debug > 2 && count > 1)
 						printk("%s: receiving %d DMA frames\n", dev->name, count);
 					dma_rx(dev);
 					if (--count == 0)
@@ -1651,12 +1578,12 @@ net_rx(struct net_device *dev)
 		skb->data[length-1] = ioread16(lp->virt_addr + RX_FRAME_PORT);
 
 	if (net_debug > 3) {
-		printk(	"%s: received %d byte packet of type %x\n",
-			dev->name, length,
-			(skb->data[ETH_ALEN+ETH_ALEN] << 8) | skb->data[ETH_ALEN+ETH_ALEN+1]);
+		printk("%s: received %d byte packet of type %x\n",
+		       dev->name, length,
+		       (skb->data[ETH_ALEN + ETH_ALEN] << 8) | skb->data[ETH_ALEN + ETH_ALEN + 1]);
 	}
 
-        skb->protocol=eth_type_trans(skb,dev);
+	skb->protocol = eth_type_trans(skb, dev);
 	netif_rx(skb);
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += length;
@@ -1700,8 +1627,9 @@ net_close(struct net_device *dev)
 	return 0;
 }
 
-/* Get the current statistics.	This may be called with the card open or
-   closed. */
+/* Get the current statistics.
+ * This may be called with the card open or closed.
+ */
 static struct net_device_stats *
 net_get_stats(struct net_device *dev)
 {
@@ -1723,7 +1651,7 @@ static void set_multicast_list(struct net_device *dev)
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
-	if(dev->flags&IFF_PROMISC)
+	if (dev->flags&IFF_PROMISC)
 	{
 		lp->rx_mode = RX_ALL_ACCEPT;
 	}
@@ -1740,7 +1668,7 @@ static void set_multicast_list(struct net_device *dev)
 
 	/* in promiscuous mode, we accept errored packets, so we have to enable interrupts on them also */
 	writereg(dev, PP_RxCFG, lp->curr_rx_cfg |
-	     (lp->rx_mode == RX_ALL_ACCEPT? (RX_CRC_ERROR_ENBL|RX_RUNT_ENBL|RX_EXTRA_DATA_ENBL) : 0));
+		 (lp->rx_mode == RX_ALL_ACCEPT ? (RX_CRC_ERROR_ENBL|RX_RUNT_ENBL|RX_EXTRA_DATA_ENBL) : 0));
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
@@ -1760,8 +1688,8 @@ static int set_mac_address(struct net_device *dev, void *p)
 		       dev->name, dev->dev_addr);
 
 	/* set the Ethernet address */
-	for (i=0; i < ETH_ALEN/2; i++)
-		writereg(dev, PP_IA+i*2, dev->dev_addr[i*2] | (dev->dev_addr[i*2+1] << 8));
+	for (i = 0; i < ETH_ALEN / 2; i++)
+		writereg(dev, PP_IA + i * 2, dev->dev_addr[i * 2] | (dev->dev_addr[i * 2 + 1] << 8));
 
 	return 0;
 }
@@ -1770,8 +1698,7 @@ static int set_mac_address(struct net_device *dev, void *p)
 
 static struct net_device *dev_cs89x0;
 
-/*
- * Support the 'debug' module parm even if we're compiled for non-debug to
+/* Support the 'debug' module parm even if we're compiled for non-debug to
  * avoid breaking someone's startup scripts
  */
 
@@ -1779,11 +1706,11 @@ static int io;
 static int irq;
 static int debug;
 static char media[8];
-static int duplex=-1;
+static int duplex = -1;
 
 static int use_dma;			/* These generate unused var warnings if ALLOW_DMA = 0 */
 static int dma;
-static int dmasize=16;			/* or 64 */
+static int dmasize = 16;		/* or 64 */
 
 module_param(io, int, 0);
 module_param(irq, int, 0);
@@ -1816,32 +1743,28 @@ MODULE_PARM_DESC(use_dma , "(ignored)");
 MODULE_AUTHOR("Mike Cruse, Russwll Nelson <nelson@crynwr.com>, Andrew Morton");
 MODULE_LICENSE("GPL");
 
-
 /*
-* media=t             - specify media type
-   or media=2
-   or media=aui
-   or medai=auto
-* duplex=0            - specify forced half/full/autonegotiate duplex
-* debug=#             - debug level
-
-
-* Default Chip Configuration:
-  * DMA Burst = enabled
-  * IOCHRDY Enabled = enabled
-    * UseSA = enabled
-    * CS8900 defaults to half-duplex if not specified on command-line
-    * CS8920 defaults to autoneg if not specified on command-line
-    * Use reset defaults for other config parameters
-
-* Assumptions:
-  * media type specified is supported (circuitry is present)
-  * if memory address is > 1MB, then required mem decode hw is present
-  * if 10B-2, then agent other than driver will enable DC/DC converter
-    (hw or software util)
-
-
-*/
+ * media=t             - specify media type
+ * or media=2
+ * or media=aui
+ * or medai=auto
+ * duplex=0            - specify forced half/full/autonegotiate duplex
+ * debug=#             - debug level
+ *
+ * Default Chip Configuration:
+ * DMA Burst = enabled
+ * IOCHRDY Enabled = enabled
+ * UseSA = enabled
+ * CS8900 defaults to half-duplex if not specified on command-line
+ * CS8920 defaults to autoneg if not specified on command-line
+ * Use reset defaults for other config parameters
+ *
+ * Assumptions:
+ * media type specified is supported (circuitry is present)
+ * if memory address is > 1MB, then required mem decode hw is present
+ * if 10B-2, then agent other than driver will enable DC/DC converter
+ * (hw or software util)
+ */
 
 int __init init_module(void)
 {
@@ -1871,8 +1794,8 @@ int __init init_module(void)
 
 	spin_lock_init(&lp->lock);
 
-        /* boy, they'd better get these right */
-        if (!strcmp(media, "rj45"))
+	/* boy, they'd better get these right */
+	if (!strcmp(media, "rj45"))
 		lp->adapter_cnf = A_CNF_MEDIA_10B_T | A_CNF_10B_T;
 	else if (!strcmp(media, "aui"))
 		lp->adapter_cnf = A_CNF_MEDIA_AUI   | A_CNF_AUI;
@@ -1881,15 +1804,15 @@ int __init init_module(void)
 	else
 		lp->adapter_cnf = A_CNF_MEDIA_10B_T | A_CNF_10B_T;
 
-        if (duplex==-1)
+	if (duplex == -1)
 		lp->auto_neg_cnf = AUTO_NEG_ENABLE;
 
-        if (io == 0) {
-                printk(KERN_ERR "cs89x0.c: Module autoprobing not allowed.\n");
-                printk(KERN_ERR "cs89x0.c: Append io=0xNNN\n");
-                ret = -EPERM;
+	if (io == 0) {
+		printk(KERN_ERR "cs89x0.c: Module autoprobing not allowed.\n");
+		printk(KERN_ERR "cs89x0.c: Append io=0xNNN\n");
+		ret = -EPERM;
 		goto out;
-        } else if (io <= 0x1ff) {
+	} else if (io <= 0x1ff) {
 		ret = -ENXIO;
 		goto out;
 	}
@@ -1985,8 +1908,7 @@ static int cs89x0_platform_remove(struct platform_device *pdev)
 	struct net_local *lp = netdev_priv(dev);
 	struct resource *mem_res;
 
-	/*
-	 * This platform_get_resource() call will not return NULL, because
+	/* This platform_get_resource() call will not return NULL, because
 	 * the same call in cs89x0_platform_probe() has returned a non NULL
 	 * value.
 	 */
@@ -2021,13 +1943,3 @@ static void __exit cs89x0_cleanup(void)
 module_exit(cs89x0_cleanup);
 
 #endif /* CONFIG_CS89x0_PLATFORM */
-
-/*
- * Local variables:
- *  version-control: t
- *  kept-new-versions: 5
- *  c-indent-level: 8
- *  tab-width: 8
- * End:
- *
- */
-- 
1.7.8.111.gad25c.dirty
