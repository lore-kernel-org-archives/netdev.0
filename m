From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Drop ISA dependencies for IRDA #2
Date: 16 Jul 2004 07:51:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040716055136.GB21819@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
Date: Fri, 16 Jul 2004 07:51:36 +0200
To: jt@hpl.hp.com, jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This incorporates the changes suggested by Martin Diehl. 

Drop CONFIG_ISA dependencies for IRDA drivers. These chips 
really hang of a LPC bus, which doesn't have a special CONFIG.

This makes them build on x86-64

Please apply.

diff -u linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig-o linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig
--- linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig-o	2004-07-12 06:09:05.000000000 +0200
+++ linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig	2004-07-15 18:33:48.000000000 +0200
@@ -310,7 +310,7 @@
 
 config NSC_FIR
 	tristate "NSC PC87108/PC87338"
-	depends on IRDA && ISA
+	depends on IRDA
 	help
 	  Say Y here if you want to build support for the NSC PC87108 and
 	  PC87338 IrDA chipsets.  This driver supports SIR,
@@ -321,7 +321,7 @@
 
 config WINBOND_FIR
 	tristate "Winbond W83977AF (IR)"
-	depends on IRDA && ISA
+	depends on IRDA
 	help
 	  Say Y here if you want to build IrDA support for the Winbond
 	  W83977AF super-io chipset.  This driver should be used for the IrDA
@@ -347,7 +347,7 @@
 
 config SMC_IRCC_FIR
 	tristate "SMSC IrCC (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && ISA
+	depends on EXPERIMENTAL && IRDA
 	help
 	  Say Y here if you want to build support for the SMC Infrared
 	  Communications Controller.  It is used in a wide variety of
@@ -357,7 +357,7 @@
 
 config ALI_FIR
 	tristate "ALi M5123 FIR (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && ISA
+	depends on EXPERIMENTAL && IRDA
 	help
 	  Say Y here if you want to build support for the ALi M5123 FIR
 	  Controller.  The ALi M5123 FIR Controller is embedded in ALi M1543C,
@@ -385,7 +385,7 @@
 
 config VIA_FIR
 	tristate "VIA VT8231/VT1211 SIR/MIR/FIR"
-	depends on IRDA && ISA
+	depends on IRDA
 	help
 	  Say Y here if you want to build support for the VIA VT8231
 	  and VIA VT1211 IrDA controllers, found on the motherboards using
diff -u linux-2.6.8rc1-amd64/include/net/irda/irda_device.h-o linux-2.6.8rc1-amd64/include/net/irda/irda_device.h
--- linux-2.6.8rc1-amd64/include/net/irda/irda_device.h-o	2004-07-12 06:09:09.000000000 +0200
+++ linux-2.6.8rc1-amd64/include/net/irda/irda_device.h	2004-07-16 07:47:20.000000000 +0200
@@ -237,9 +237,7 @@
 dongle_t *irda_device_dongle_init(struct net_device *dev, int type);
 int irda_device_dongle_cleanup(dongle_t *dongle);
 
-#ifdef CONFIG_ISA
 void irda_setup_dma(int channel, dma_addr_t buffer, int count, int mode);
-#endif
 
 void irda_task_delete(struct irda_task *task);
 struct irda_task *irda_task_execute(void *instance, 
diff -u linux-2.6.8rc1-amd64/net/sunrpc/svcauth.c-o linux-2.6.8rc1-amd64/net/sunrpc/svcauth.c
diff -u linux-2.6.8rc1-amd64/net/irda/irda_device.c-o linux-2.6.8rc1-amd64/net/irda/irda_device.c
--- linux-2.6.8rc1-amd64/net/irda/irda_device.c-o	2004-07-12 06:09:10.000000000 +0200
+++ linux-2.6.8rc1-amd64/net/irda/irda_device.c	2004-07-16 07:47:14.000000000 +0200
@@ -529,11 +529,10 @@
 	return ret;
 }
 
-#ifdef CONFIG_ISA
 /*
  * Function setup_dma (idev, buffer, count, mode)
  *
- *    Setup the DMA channel. Commonly used by ISA FIR drivers
+ *    Setup the DMA channel. Commonly used by LPC FIR drivers
  *
  */
 void irda_setup_dma(int channel, dma_addr_t buffer, int count, int mode)
@@ -552,4 +551,3 @@
 	release_dma_lock(flags);
 }
 EXPORT_SYMBOL(irda_setup_dma);
-#endif
