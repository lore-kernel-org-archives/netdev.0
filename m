From: janitor@sternwelten.at
Subject: [patch 1/4]  net/ne2k-pci: module_param conversion
Date: Sat, 20 Nov 2004 03:45:00 +0100
Message-ID: <E1CVLFE-0002CL-PU@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, domen@coderock.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hi.

Simple module_param_array conversions.
Get rid of debug option, since it's only used once.
Add some KERN_* constants to printk's.

Compile tested.

Signed-off-by: Domen Puncer <domen@coderock.org>

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
---

 linux-2.6.10-rc2-bk4-max/drivers/net/ne2k-pci.c |   25 +++++++-----------------
 1 files changed, 8 insertions(+), 17 deletions(-)

diff -puN drivers/net/ne2k-pci.c~module_parm-net_ne2k-pci drivers/net/ne2k-pci.c
--- linux-2.6.10-rc2-bk4/drivers/net/ne2k-pci.c~module_parm-net_ne2k-pci	2004-11-20 03:04:54.000000000 +0100
+++ linux-2.6.10-rc2-bk4-max/drivers/net/ne2k-pci.c	2004-11-20 03:04:54.000000000 +0100
@@ -29,12 +29,6 @@
 #define DRV_VERSION	"1.03"
 #define DRV_RELDATE	"9/22/2003"
 
-
-/* The user-configurable values.
-   These may be modified when a driver module is loaded.*/
-
-static int debug = 1;			/* 1 normal messages, 0 quiet .. 7 verbose. */
-
 #define MAX_UNITS 8				/* More are supported, limit only on options */
 /* Used to pass the full-duplex flag, etc. */
 static int full_duplex[MAX_UNITS];
@@ -77,10 +71,8 @@ MODULE_AUTHOR("Donald Becker / Paul Gort
 MODULE_DESCRIPTION("PCI NE2000 clone driver");
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(debug, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM_DESC(debug, "debug level (1-2)");
+module_param_array(options, int, NULL, 0);
+module_param_array(full_duplex, int, NULL, 0);
 MODULE_PARM_DESC(options, "Bit 5: full duplex");
 MODULE_PARM_DESC(full_duplex, "full duplex setting(s) (1)");
 
@@ -366,7 +358,7 @@ static int __devinit ne2k_pci_init_one (
 	if (i)
 		goto err_out_free_netdev;
 
-	printk("%s: %s found at %#lx, IRQ %d, ",
+	printk(KERN_INFO "%s: %s found at %#lx, IRQ %d, ",
 		   dev->name, pci_clone_list[chip_idx].name, ioaddr, dev->irq);
 	for(i = 0; i < 6; i++) {
 		printk("%2.2X%s", SA_prom[i], i == 5 ? ".\n": ":");
@@ -443,8 +435,7 @@ static void ne2k_pci_reset_8390(struct n
 {
 	unsigned long reset_start_time = jiffies;
 
-	if (debug > 1) printk("%s: Resetting the 8390 t=%ld...",
-						  dev->name, jiffies);
+	printk(KERN_INFO "%s: Resetting the 8390 t=%ld...", dev->name, jiffies);
 
 	outb(inb(NE_BASE + NE_RESET), NE_BASE + NE_RESET);
 
@@ -454,7 +445,7 @@ static void ne2k_pci_reset_8390(struct n
 	/* This check _should_not_ be necessary, omit eventually. */
 	while ((inb(NE_BASE+EN0_ISR) & ENISR_RESET) == 0)
 		if (jiffies - reset_start_time > 2) {
-			printk("%s: ne2k_pci_reset_8390() did not complete.\n", dev->name);
+			printk(KERN_NOTICE "%s: ne2k_pci_reset_8390() did not complete.\n", dev->name);
 			break;
 		}
 	outb(ENISR_RESET, NE_BASE + EN0_ISR);	/* Ack intr. */
@@ -471,7 +462,7 @@ static void ne2k_pci_get_8390_hdr(struct
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing) {
-		printk("%s: DMAing conflict in ne2k_pci_get_8390_hdr "
+		printk(KERN_ERR "%s: DMAing conflict in ne2k_pci_get_8390_hdr "
 			   "[DMAstat:%d][irqlock:%d].\n",
 			   dev->name, ei_status.dmaing, ei_status.irqlock);
 		return;
@@ -509,7 +500,7 @@ static void ne2k_pci_block_input(struct 
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing) {
-		printk("%s: DMAing conflict in ne2k_pci_block_input "
+		printk(KERN_ERR "%s: DMAing conflict in ne2k_pci_block_input "
 			   "[DMAstat:%d][irqlock:%d].\n",
 			   dev->name, ei_status.dmaing, ei_status.irqlock);
 		return;
@@ -564,7 +555,7 @@ static void ne2k_pci_block_output(struct
 
 	/* This *shouldn't* happen. If it does, it's the last thing you'll see */
 	if (ei_status.dmaing) {
-		printk("%s: DMAing conflict in ne2k_pci_block_output."
+		printk(KERN_ERR "%s: DMAing conflict in ne2k_pci_block_output."
 			   "[DMAstat:%d][irqlock:%d]\n",
 			   dev->name, ei_status.dmaing, ei_status.irqlock);
 		return;
_
