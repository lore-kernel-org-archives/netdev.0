From: Roger Luethi <rl@hellgate.ch>
Subject: [4/4][PATCH 2.6] via-rhine: USE_MEM, USE_IO -> USE_MMIO
Date: Sun, 23 May 2004 12:50:18 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040523105018.GA10472@k3.hellgate.ch>
References: <20040523104650.GA9979@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="liOOAslEiF7prFVr"
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262476AbUEWLCr@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040523104650.GA9979@k3.hellgate.ch>
List-Id: netdev.vger.kernel.org


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Replace USE_MEM and USE_IO with USE_MMIO define.

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="via-rhine-2.6.6-4-defmem.diff"

--- linux-2.6.6/drivers/net/via-rhine.c	2004-05-23 11:38:22.798939458 +0200
+++ linux-2.6.6-patch/drivers/net/via-rhine.c	2004-05-23 11:44:18.972292582 +0200
@@ -222,9 +222,8 @@ static char shortname[] = DRV_NAME;
 /* This driver was written to use PCI memory space, however most versions
    of the Rhine only work correctly with I/O space accesses. */
 #ifdef CONFIG_VIA_RHINE_MMIO
-#define USE_MEM
+#define USE_MMIO
 #else
-#define USE_IO
 #undef readb
 #undef readw
 #undef readl
@@ -380,7 +379,7 @@ enum chip_capability_flags {
 	ReqTxAlign=0x10, HasWOL=0x20,
 };
 
-#ifdef USE_MEM
+#ifdef USE_MMIO
 #define RHINE_IOTYPE (PCI_USES_MEM | PCI_USES_MASTER | PCI_ADDR1)
 #else
 #define RHINE_IOTYPE (PCI_USES_IO  | PCI_USES_MASTER | PCI_ADDR0)
@@ -432,7 +431,7 @@ enum backoff_bits {
 	BackCaptureEffect=0x04, BackRandom=0x08
 };
 
-#ifdef USE_MEM
+#ifdef USE_MMIO
 /* Registers we check that mmio and reg are the same. */
 int mmio_verify_registers[] = {
 	RxConfig, TxConfig, IntrEnable, ConfigA, ConfigB, ConfigC, ConfigD,
@@ -590,7 +589,7 @@ static void wait_for_reset(struct net_de
 			boguscnt ? "succeeded" : "failed");
 }
 
-#ifdef USE_MEM
+#ifdef USE_MMIO
 static void __devinit enable_mmio(long ioaddr, int chip_id)
 {
 	int n;
@@ -636,7 +635,7 @@ static int __devinit rhine_init_one(stru
 	long memaddr;
 	int io_size;
 	int pci_flags;
-#ifdef USE_MEM
+#ifdef USE_MMIO
 	long ioaddr0;
 #endif
 
@@ -687,7 +686,7 @@ static int __devinit rhine_init_one(stru
 	if (pci_request_regions(pdev, shortname))
 		goto err_out_free_netdev;
 
-#ifdef USE_MEM
+#ifdef USE_MMIO
 	ioaddr0 = ioaddr;
 	enable_mmio(ioaddr0, chip_id);
 
@@ -710,7 +709,7 @@ static int __devinit rhine_init_one(stru
 			goto err_out_unmap;
 		}
 	}
-#endif
+#endif /* USE_MMIO */
 
 	/* D-Link provided reset code (with comment additions) */
 	if (rhine_chip_info[chip_id].drv_flags & HasWOL) {
@@ -737,14 +736,14 @@ static int __devinit rhine_init_one(stru
 	wait_for_reset(dev, chip_id, shortname);
 
 	/* Reload the station address from the EEPROM. */
-#ifdef USE_IO
-	reload_eeprom(ioaddr);
-#else
+#ifdef USE_MMIO
 	reload_eeprom(ioaddr0);
 	/* Reloading from eeprom overwrites cfgA-D, so we must re-enable MMIO.
 	   If reload_eeprom() was done first this could be avoided, but it is
 	   not known if that still works with the "win98-reboot" problem. */
 	enable_mmio(ioaddr0, chip_id);
+#else
+	reload_eeprom(ioaddr);
 #endif
 
 	for (i = 0; i < 6; i++)
@@ -880,7 +879,7 @@ static int __devinit rhine_init_one(stru
 	return 0;
 
 err_out_unmap:
-#ifdef USE_MEM
+#ifdef USE_MMIO
 	iounmap((void *)ioaddr);
 err_out_free_res:
 #endif
@@ -1933,7 +1932,7 @@ static void __devexit rhine_remove_one(s
 
 	pci_release_regions(pdev);
 
-#ifdef USE_MEM
+#ifdef USE_MMIO
 	iounmap((char *)(dev->base_addr));
 #endif
 

--liOOAslEiF7prFVr--
