From: domen@coderock.org
Subject: [patch 1/1] drivers/net/: Use the DMA_{64,32}BIT_MASK constants
Date: Fri, 08 Apr 2005 09:52:32 +0200
Message-ID: <20050408075232.545761F39A@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, tklauser@nuerscht.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



The previous patch did not compile cleanly on all architectures so
here's a fixed one.

Use the DMA_{64,32}BIT_MASK constants from dma-mapping.h when calling
pci_set_dma_mask() or pci_set_consistent_dma_mask()
This patch includes dma-mapping.h explicitly because it caused errors
on some architectures otherwise.
See http://marc.theaimsgroup.com/?t=108001993000001&r=1&w=2 for details

Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/8139cp.c                |    9 +++++----
 kj-domen/drivers/net/acenic.c                |    5 +++--
 kj-domen/drivers/net/e100.c                  |    3 ++-
 kj-domen/drivers/net/hp100.c                 |    3 ++-
 kj-domen/drivers/net/ns83820.c               |    5 +++--
 kj-domen/drivers/net/s2io.c                  |    7 ++++---
 kj-domen/drivers/net/sis900.c                |    5 ++---
 kj-domen/drivers/net/sk98lin/skge.c          |    5 +++--
 kj-domen/drivers/net/sungem.c                |    5 +++--
 kj-domen/drivers/net/tg3.c                   |    7 ++++---
 kj-domen/drivers/net/tlan.c                  |    3 ++-
 kj-domen/drivers/net/tokenring/lanstreamer.c |    3 ++-
 kj-domen/drivers/net/tulip/dmfe.c            |    3 ++-
 kj-domen/drivers/net/tulip/winbond-840.c     |    3 ++-
 kj-domen/drivers/net/via-rhine.c             |    3 ++-
 kj-domen/drivers/net/wan/wanxl.c             |    5 +++--
 16 files changed, 44 insertions(+), 30 deletions(-)

diff -puN drivers/net/8139cp.c~dma_mask-drivers_net drivers/net/8139cp.c
--- kj/drivers/net/8139cp.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/8139cp.c	2005-04-05 12:57:45.000000000 +0200
@@ -60,6 +60,7 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/delay.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
@@ -1702,19 +1703,19 @@ static int cp_init_one (struct pci_dev *
 
 	/* Configure DMA attributes. */
 	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_consistent_dma_mask(pdev, 0xffffffffffffffffULL) &&
-	    !pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {
+	    !pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK) &&
+	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
 		pci_using_dac = 1;
 	} else {
 		pci_using_dac = 0;
 
-		rc = pci_set_dma_mask(pdev, 0xffffffffULL);
+		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (rc) {
 			printk(KERN_ERR PFX "No usable DMA configuration, "
 			       "aborting.\n");
 			goto err_out_res;
 		}
-		rc = pci_set_consistent_dma_mask(pdev, 0xffffffffULL);
+		rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 		if (rc) {
 			printk(KERN_ERR PFX "No usable consistent DMA configuration, "
 			       "aborting.\n");
diff -puN drivers/net/acenic.c~dma_mask-drivers_net drivers/net/acenic.c
--- kj/drivers/net/acenic.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/acenic.c	2005-04-05 12:57:45.000000000 +0200
@@ -58,6 +58,7 @@
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -1167,9 +1168,9 @@ static int __devinit ace_init(struct net
 	/*
 	 * Configure DMA attributes.
 	 */
-	if (!pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {
+	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
 		ap->pci_using_dac = 1;
-	} else if (!pci_set_dma_mask(pdev, 0xffffffffULL)) {
+	} else if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 		ap->pci_using_dac = 0;
 	} else {
 		ecode = -ENODEV;
diff -puN drivers/net/e100.c~dma_mask-drivers_net drivers/net/e100.c
--- kj/drivers/net/e100.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/e100.c	2005-04-05 12:57:45.000000000 +0200
@@ -143,6 +143,7 @@
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
@@ -2201,7 +2202,7 @@ static int __devinit e100_probe(struct p
 		goto err_out_disable_pdev;
 	}
 
-	if((err = pci_set_dma_mask(pdev, 0xFFFFFFFFULL))) {
+	if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
 		goto err_out_free_res;
 	}
diff -puN drivers/net/hp100.c~dma_mask-drivers_net drivers/net/hp100.c
--- kj/drivers/net/hp100.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/hp100.c	2005-04-05 12:57:45.000000000 +0200
@@ -106,6 +106,7 @@
 #include <linux/interrupt.h>
 #include <linux/eisa.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/spinlock.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -562,7 +563,7 @@ static int __devinit hp100_probe1(struct
 			 * Also, we can have EISA Busmaster cards (not tested),
 			 * so beware !!! - Jean II */
 			if((bus == HP100_BUS_PCI) &&
-			   (pci_set_dma_mask(pci_dev, 0xffffffff))) {
+			   (pci_set_dma_mask(pci_dev, DMA_32BIT_MASK))) {
 				/* Gracefully fallback to shared memory */
 				goto busmasterfail;
 			}
diff -puN drivers/net/ns83820.c~dma_mask-drivers_net drivers/net/ns83820.c
--- kj/drivers/net/ns83820.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/ns83820.c	2005-04-05 12:57:45.000000000 +0200
@@ -99,6 +99,7 @@
 #include <linux/moduleparam.h>
 #include <linux/types.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
@@ -1841,9 +1842,9 @@ static int __devinit ns83820_init_one(st
 	int using_dac = 0;
 
 	/* See if we can set the dma mask early on; failure is fatal. */
-	if (TRY_DAC && !pci_set_dma_mask(pci_dev, 0xffffffffffffffffULL)) {
+	if (TRY_DAC && !pci_set_dma_mask(pci_dev, DMA_64BIT_MASK)) {
 		using_dac = 1;
-	} else if (!pci_set_dma_mask(pci_dev, 0xffffffff)) {
+	} else if (!pci_set_dma_mask(pci_dev, DMA_32BIT_MASK)) {
 		using_dac = 0;
 	} else {
 		printk(KERN_WARNING "ns83820.c: pci_set_dma_mask failed!\n");
diff -puN drivers/net/s2io.c~dma_mask-drivers_net drivers/net/s2io.c
--- kj/drivers/net/s2io.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/s2io.c	2005-04-05 12:57:45.000000000 +0200
@@ -42,6 +42,7 @@
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -4593,19 +4594,19 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		return ret;
 	}
 
-	if (!pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {
+	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
 		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 64bit DMA\n");
 		dma_flag = TRUE;
 
 		if (pci_set_consistent_dma_mask
-		    (pdev, 0xffffffffffffffffULL)) {
+		    (pdev, DMA_64BIT_MASK)) {
 			DBG_PRINT(ERR_DBG,
 				  "Unable to obtain 64bit DMA for \
 					consistent allocations\n");
 			pci_disable_device(pdev);
 			return -ENOMEM;
 		}
-	} else if (!pci_set_dma_mask(pdev, 0xffffffffUL)) {
+	} else if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 32bit DMA\n");
 	} else {
 		pci_disable_device(pdev);
diff -puN drivers/net/sis900.c~dma_mask-drivers_net drivers/net/sis900.c
--- kj/drivers/net/sis900.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/sis900.c	2005-04-05 12:57:45.000000000 +0200
@@ -66,6 +66,7 @@
 #include <linux/ethtool.h>
 #include <linux/crc32.h>
 #include <linux/bitops.h>
+#include <linux/dma-mapping.h>
 
 #include <asm/processor.h>      /* Processor type for cache alignment. */
 #include <asm/io.h>
@@ -93,8 +94,6 @@ static int sis900_debug = -1; /* Use SIS
 
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (4*HZ)
-/* SiS 900 is capable of 32 bits BM DMA */
-#define SIS900_DMA_MASK 0xffffffff
 
 enum {
 	SIS_900 = 0,
@@ -413,7 +412,7 @@ static int __devinit sis900_probe(struct
 	ret = pci_enable_device(pci_dev);
 	if(ret) return ret;
 	
-	i = pci_set_dma_mask(pci_dev, SIS900_DMA_MASK);
+	i = pci_set_dma_mask(pci_dev, DMA_32BIT_MASK);
 	if(i){
 		printk(KERN_ERR "sis900.c: architecture does not support"
 			"32bit PCI busmaster DMA\n");
diff -puN drivers/net/sk98lin/skge.c~dma_mask-drivers_net drivers/net/sk98lin/skge.c
--- kj/drivers/net/sk98lin/skge.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/sk98lin/skge.c	2005-04-05 12:57:45.000000000 +0200
@@ -112,6 +112,7 @@
 #include	<linux/moduleparam.h>
 #include	<linux/init.h>
 #include 	<linux/proc_fs.h>
+#include	<linux/dma-mapping.h>
 
 #include	"h/skdrv1st.h"
 #include	"h/skdrv2nd.h"
@@ -4912,8 +4913,8 @@ static int __devinit skge_probe_one(stru
 		goto out;
  
 	/* Configure DMA attributes. */
-	if (pci_set_dma_mask(pdev, (u64) 0xffffffffffffffffULL) &&
-	    pci_set_dma_mask(pdev, (u64) 0xffffffff))
+	if (pci_set_dma_mask(pdev, DMA_64BIT_MASK) &&
+	    pci_set_dma_mask(pdev, DMA_32BIT_MASK))
 		goto out_disable_device;
 
 
diff -puN drivers/net/sungem.c~dma_mask-drivers_net drivers/net/sungem.c
--- kj/drivers/net/sungem.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/sungem.c	2005-04-05 12:57:45.000000000 +0200
@@ -44,6 +44,7 @@
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
@@ -2989,10 +2990,10 @@ static int __devinit gem_init_one(struct
 	 */
 	if (pdev->vendor == PCI_VENDOR_ID_SUN &&
 	    pdev->device == PCI_DEVICE_ID_SUN_GEM &&
-	    !pci_set_dma_mask(pdev, (u64) 0xffffffffffffffffULL)) {
+	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
 		pci_using_dac = 1;
 	} else {
-		err = pci_set_dma_mask(pdev, (u64) 0xffffffff);
+		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
 			printk(KERN_ERR PFX "No usable DMA configuration, "
 			       "aborting.\n");
diff -puN drivers/net/tg3.c~dma_mask-drivers_net drivers/net/tg3.c
--- kj/drivers/net/tg3.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/tg3.c	2005-04-05 12:57:45.000000000 +0200
@@ -22,6 +22,7 @@
 #include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
@@ -8702,17 +8703,17 @@ static int __devinit tg3_init_one(struct
 	}
 
 	/* Configure DMA attributes. */
-	err = pci_set_dma_mask(pdev, 0xffffffffffffffffULL);
+	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
 	if (!err) {
 		pci_using_dac = 1;
-		err = pci_set_consistent_dma_mask(pdev, 0xffffffffffffffffULL);
+		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
 		if (err < 0) {
 			printk(KERN_ERR PFX "Unable to obtain 64 bit DMA "
 			       "for consistent allocations\n");
 			goto err_out_free_res;
 		}
 	} else {
-		err = pci_set_dma_mask(pdev, 0xffffffffULL);
+		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
 			printk(KERN_ERR PFX "No usable DMA configuration, "
 			       "aborting.\n");
diff -puN drivers/net/tlan.c~dma_mask-drivers_net drivers/net/tlan.c
--- kj/drivers/net/tlan.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/tlan.c	2005-04-05 12:57:45.000000000 +0200
@@ -171,6 +171,7 @@
 #include <linux/ioport.h>
 #include <linux/eisa.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
@@ -555,7 +556,7 @@ static int __devinit TLan_probe1(struct 
 
 		priv->adapter = &board_info[ent->driver_data];
 
-		rc = pci_set_dma_mask(pdev, 0xFFFFFFFF);
+		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (rc) {
 			printk(KERN_ERR "TLAN: No suitable PCI mapping available.\n");
 			goto err_out_free_dev;
diff -puN drivers/net/tokenring/lanstreamer.c~dma_mask-drivers_net drivers/net/tokenring/lanstreamer.c
--- kj/drivers/net/tokenring/lanstreamer.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/tokenring/lanstreamer.c	2005-04-05 12:57:45.000000000 +0200
@@ -118,6 +118,7 @@
 #include <linux/stddef.h>
 #include <linux/init.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/spinlock.h>
 #include <linux/version.h>
 #include <linux/bitops.h>
@@ -258,7 +259,7 @@ static int __devinit streamer_init_one(s
 #endif
 #endif
 
-	rc = pci_set_dma_mask(pdev, 0xFFFFFFFFULL);
+	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if (rc) {
 		printk(KERN_ERR "%s: No suitable PCI mapping available.\n",
 				dev->name);
diff -puN drivers/net/tulip/dmfe.c~dma_mask-drivers_net drivers/net/tulip/dmfe.c
--- kj/drivers/net/tulip/dmfe.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/tulip/dmfe.c	2005-04-05 12:57:45.000000000 +0200
@@ -78,6 +78,7 @@
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -354,7 +355,7 @@ static int __devinit dmfe_init_one (stru
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	if (pci_set_dma_mask(pdev, 0xffffffff)) {
+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 		printk(KERN_WARNING DRV_NAME ": 32-bit PCI DMA not available.\n");
 		err = -ENODEV;
 		goto err_out_free;
diff -puN drivers/net/tulip/winbond-840.c~dma_mask-drivers_net drivers/net/tulip/winbond-840.c
--- kj/drivers/net/tulip/winbond-840.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/tulip/winbond-840.c	2005-04-05 12:57:45.000000000 +0200
@@ -121,6 +121,7 @@ static int full_duplex[MAX_UNITS] = {-1,
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
@@ -394,7 +395,7 @@ static int __devinit w840_probe1 (struct
 
 	irq = pdev->irq;
 
-	if (pci_set_dma_mask(pdev,0xFFFFffff)) {
+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 		printk(KERN_WARNING "Winbond-840: Device %s disabled due to DMA limitations.\n",
 		       pci_name(pdev));
 		return -EIO;
diff -puN drivers/net/via-rhine.c~dma_mask-drivers_net drivers/net/via-rhine.c
--- kj/drivers/net/via-rhine.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/via-rhine.c	2005-04-05 12:57:45.000000000 +0200
@@ -186,6 +186,7 @@ static const int multicast_filter_limit 
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
@@ -740,7 +741,7 @@ static int __devinit rhine_init_one(stru
 		goto err_out;
 
 	/* this should always be supported */
-	rc = pci_set_dma_mask(pdev, 0xffffffff);
+	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if (rc) {
 		printk(KERN_ERR "32-bit PCI DMA addresses not supported by "
 		       "the card!?\n");
diff -puN drivers/net/wan/wanxl.c~dma_mask-drivers_net drivers/net/wan/wanxl.c
--- kj/drivers/net/wan/wanxl.c~dma_mask-drivers_net	2005-04-05 12:57:45.000000000 +0200
+++ kj-domen/drivers/net/wan/wanxl.c	2005-04-05 12:57:45.000000000 +0200
@@ -26,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/hdlc.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <asm/io.h>
 #include <asm/delay.h>
 
@@ -624,8 +625,8 @@ static int __devinit wanxl_pci_init_one(
 	/* FIXME when PCI/DMA subsystems are fixed.
 	   We set both dma_mask and consistent_dma_mask back to 32 bits
 	   to indicate the card can do 32-bit DMA addressing */
-	if (pci_set_consistent_dma_mask(pdev, 0xFFFFFFFF) ||
-	    pci_set_dma_mask(pdev, 0xFFFFFFFF)) {
+	if (pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK) ||
+	    pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 		printk(KERN_ERR "wanXL: No usable DMA configuration\n");
 		wanxl_pci_remove_one(pdev);
 		return -EIO;
_
