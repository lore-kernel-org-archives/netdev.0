From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] remove concat. with __FUNCTION__ (drivers/net/)
Date: Tue, 6 Apr 2004 14:45:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040406144556.78c971a2.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Tony Breeds <tony@bakeyournoodle.com>

"concatenation of string literals with __FUNCTION__ is deprecated"


---

 drivers/net/gt96100eth.c       |    2 +-
 drivers/net/irda/smsc-ircc2.c  |    6 +++---
 drivers/net/irda/via-ircc.c    |    2 +-
 drivers/net/wireless/orinoco.h |    4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff -puN drivers/net/gt96100eth.c~remove_concat_FUNCTION_drivers drivers/net/gt96100eth.c
--- linux-265-kj1/drivers/net/gt96100eth.c~remove_concat_FUNCTION_drivers	2004-04-05 13:31:23.000000000 -0700
+++ linux-265-kj1-rddunlap/drivers/net/gt96100eth.c	2004-04-05 13:31:23.000000000 -0700
@@ -1212,7 +1212,7 @@ gt96100_rx(struct net_device *dev, u32 s
 		    cmdstat, nextOut);
 
 		if (cmdstat & (u32)rxOwn) {
-			//err(__FUNCTION__ ": device owns descriptor!\n");
+			//err("%s: device owns descriptor!\n", __FUNCTION__);
 			// DMA is not finished updating descriptor???
 			// Leave and come back later to pick-up where
 			// we left off.
diff -puN drivers/net/irda/smsc-ircc2.c~remove_concat_FUNCTION_drivers drivers/net/irda/smsc-ircc2.c
--- linux-265-kj1/drivers/net/irda/smsc-ircc2.c~remove_concat_FUNCTION_drivers	2004-04-05 13:31:23.000000000 -0700
+++ linux-265-kj1-rddunlap/drivers/net/irda/smsc-ircc2.c	2004-04-05 13:31:23.000000000 -0700
@@ -1429,7 +1429,7 @@ static irqreturn_t smsc_ircc_interrupt(i
 	}
 
 	if (iir & IRCC_IIR_ACTIVE_FRAME) {
-		/*printk(KERN_WARNING __FUNCTION__ "(): Active Frame\n");*/
+		/*printk(KERN_WARNING "%s(): Active Frame\n", __FUNCTION__);*/
 	}
 
 	/* Enable interrupts again */
@@ -1995,7 +1995,7 @@ static int __init smsc_ircc_look_for_chi
 	while(address->cfg_base){
 		cfg_base = address->cfg_base;
 		
-		/*printk(KERN_WARNING __FUNCTION__ "(): probing: 0x%02x for: 0x%02x\n", cfg_base, address->type);*/
+		/*printk(KERN_WARNING "%s(): probing: 0x%02x for: 0x%02x\n", __FUNCTION__, cfg_base, address->type);*/
 		
 		if( address->type & SMSCSIO_TYPE_FDC){
 			type = "FDC";
@@ -2040,7 +2040,7 @@ static int __init smsc_superio_flat(cons
 	outb(SMSCSIOFLAT_UARTMODE0C_REG, cfgbase);
 	mode = inb(cfgbase+1);
 	
-	/*printk(KERN_WARNING __FUNCTION__ "(): mode: 0x%02x\n", mode);*/
+	/*printk(KERN_WARNING "%s(): mode: 0x%02x\n", __FUNCTION__, mode);*/
 	
 	if(!(mode & SMSCSIOFLAT_UART2MODE_VAL_IRDA))
 		WARNING("%s(): IrDA not enabled\n", __FUNCTION__);
diff -puN drivers/net/irda/via-ircc.c~remove_concat_FUNCTION_drivers drivers/net/irda/via-ircc.c
--- linux-265-kj1/drivers/net/irda/via-ircc.c~remove_concat_FUNCTION_drivers	2004-04-05 13:31:23.000000000 -0700
+++ linux-265-kj1-rddunlap/drivers/net/irda/via-ircc.c	2004-04-05 13:31:23.000000000 -0700
@@ -360,7 +360,7 @@ static __devinit int via_ircc_open(int i
 
 	/* Reserve the ioports that we need */
 	if (!request_region(self->io.fir_base, self->io.fir_ext, driver_name)) {
-//              WARNING(__FUNCTION__ "(), can't get iobase of 0x%03x\n",self->io.fir_base);
+//              WARNING("%s(), can't get iobase of 0x%03x\n", __FUNCTION__, self->io.fir_base);
 		err = -ENODEV;
 		goto err_out1;
 	}
diff -puN drivers/net/wireless/orinoco.h~remove_concat_FUNCTION_drivers drivers/net/wireless/orinoco.h
--- linux-265-kj1/drivers/net/wireless/orinoco.h~remove_concat_FUNCTION_drivers	2004-04-05 13:31:23.000000000 -0700
+++ linux-265-kj1-rddunlap/drivers/net/wireless/orinoco.h	2004-04-05 13:31:23.000000000 -0700
@@ -125,8 +125,8 @@ extern int orinoco_debug;
 #define DEBUG(n, args...) do { } while (0)
 #endif	/* ORINOCO_DEBUG */
 
-#define TRACE_ENTER(devname) DEBUG(2, "%s: -> " __FUNCTION__ "()\n", devname);
-#define TRACE_EXIT(devname)  DEBUG(2, "%s: <- " __FUNCTION__ "()\n", devname);
+#define TRACE_ENTER(devname) DEBUG(2, "%s: -> %s()\n", __FUNCTION__, devname);
+#define TRACE_EXIT(devname)  DEBUG(2, "%s: <- %s()\n", __FUNCTION__, devname);
 
 extern struct net_device *alloc_orinocodev(int sizeof_card,
 					   int (*hard_reset)(struct orinoco_private *));
