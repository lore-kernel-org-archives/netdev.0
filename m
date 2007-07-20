From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] defxx: Use __maybe_unused rather than a local hack
Date: Fri, 20 Jul 2007 13:14:07 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0707201310060.7402@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763474AbXGTMOh@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 This is a change to remove a local hack in favour to __maybe_unused that 
has been recently added.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
Hi,

 It should be obvious.  The code builds, therefore it works.

 Please apply,

  Maciej

patch-mips-2.6.22-20070710-defxx-unused-0
diff -up --recursive --new-file linux-mips-2.6.22-20070710.macro/drivers/net/defxx.c linux-mips-2.6.22-20070710/drivers/net/defxx.c
--- linux-mips-2.6.22-20070710.macro/drivers/net/defxx.c	2007-07-10 04:56:16.000000000 +0000
+++ linux-mips-2.6.22-20070710/drivers/net/defxx.c	2007-07-20 00:05:14.000000000 +0000
@@ -200,6 +200,7 @@
 
 /* Include files */
 #include <linux/bitops.h>
+#include <linux/compiler.h>
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
 #include <linux/eisa.h>
@@ -240,8 +241,6 @@ static char version[] __devinitdata =
  */
 #define NEW_SKB_SIZE (PI_RCV_DATA_K_SIZE_MAX+128)
 
-#define __unused __attribute__ ((unused))
-
 #ifdef CONFIG_PCI
 #define DFX_BUS_PCI(dev) (dev->bus == &pci_bus_type)
 #else
@@ -375,7 +374,7 @@ static inline void dfx_outl(DFX_board_t 
 
 static void dfx_port_write_long(DFX_board_t *bp, int offset, u32 data)
 {
-	struct device __unused *bdev = bp->bus_dev;
+	struct device __maybe_unused *bdev = bp->bus_dev;
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
 
@@ -399,7 +398,7 @@ static inline void dfx_inl(DFX_board_t *
 
 static void dfx_port_read_long(DFX_board_t *bp, int offset, u32 *data)
 {
-	struct device __unused *bdev = bp->bus_dev;
+	struct device __maybe_unused *bdev = bp->bus_dev;
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
 
@@ -866,7 +865,7 @@ static void __devinit dfx_bus_uninit(str
 
 static void __devinit dfx_bus_config_check(DFX_board_t *bp)
 {
-	struct device __unused *bdev = bp->bus_dev;
+	struct device __maybe_unused *bdev = bp->bus_dev;
 	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
 	int	status;				/* return code from adapter port control call */
 	u32	host_data;			/* LW data returned from port control call */
@@ -3624,8 +3623,8 @@ static void __devexit dfx_unregister(str
 }
 
 
-static int __devinit __unused dfx_dev_register(struct device *);
-static int __devexit __unused dfx_dev_unregister(struct device *);
+static int __devinit __maybe_unused dfx_dev_register(struct device *);
+static int __devexit __maybe_unused dfx_dev_unregister(struct device *);
 
 #ifdef CONFIG_PCI
 static int __devinit dfx_pci_register(struct pci_dev *,
@@ -3699,7 +3698,7 @@ static struct tc_driver dfx_tc_driver = 
 };
 #endif /* CONFIG_TC */
 
-static int __devinit __unused dfx_dev_register(struct device *dev)
+static int __devinit __maybe_unused dfx_dev_register(struct device *dev)
 {
 	int status;
 
@@ -3709,7 +3708,7 @@ static int __devinit __unused dfx_dev_re
 	return status;
 }
 
-static int __devexit __unused dfx_dev_unregister(struct device *dev)
+static int __devexit __maybe_unused dfx_dev_unregister(struct device *dev)
 {
 	put_device(dev);
 	dfx_unregister(dev);
