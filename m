From: domen@coderock.org
Subject: [patch 26/26] drivers/net/: Use the DMA_{64,32}BIT_MASK constants
Date: Sun, 06 Mar 2005 11:34:03 +0100
Message-ID: <20050306103404.12D9C1E46E@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, tklauser@nuerscht.ch
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Use the DMA_{64,32}BIT_MASK constants from dma-mapping.h
when calling pci_set_dma_mask() or pci_set_consistent_dma_mask()

[Merged multiple patches, I can send split ones if desired -domen]

Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/8139cp.c            |    8 ++++----
 kj-domen/drivers/net/acenic.c            |    4 ++--
 kj-domen/drivers/net/e100.c              |    2 +-
 kj-domen/drivers/net/hp100.c             |    2 +-
 kj-domen/drivers/net/ns83820.c           |    4 ++--
 kj-domen/drivers/net/s2io.c              |    6 +++---
 kj-domen/drivers/net/sk98lin/skge.c      |    4 ++--
 kj-domen/drivers/net/sungem.c            |    4 ++--
 kj-domen/drivers/net/tg3.c               |    6 +++---
 kj-domen/drivers/net/tlan.c              |    2 +-
 kj-domen/drivers/net/tulip/dmfe.c        |    2 +-
 kj-domen/drivers/net/tulip/winbond-840.c |    2 +-
 kj-domen/drivers/net/via-rhine.c         |    2 +-
 kj-domen/drivers/net/wan/wanxl.c         |    4 ++--
 14 files changed, 26 insertions(+), 26 deletions(-)

diff -puN drivers/net/8139cp.c~dma_mask-drivers_net drivers/net/8139cp.c
--- kj/drivers/net/8139cp.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/8139cp.c	2005-03-05 16:13:20.000000000 +0100
@@ -1702,19 +1702,19 @@ static int cp_init_one (struct pci_dev *
 
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
--- kj/drivers/net/acenic.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/acenic.c	2005-03-05 16:13:20.000000000 +0100
@@ -1167,9 +1167,9 @@ static int __devinit ace_init(struct net
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
--- kj/drivers/net/e100.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/e100.c	2005-03-05 16:13:20.000000000 +0100
@@ -2201,7 +2201,7 @@ static int __devinit e100_probe(struct p
 		goto err_out_disable_pdev;
 	}
 
-	if((err = pci_set_dma_mask(pdev, 0xFFFFFFFFULL))) {
+	if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
 		goto err_out_free_res;
 	}
diff -puN drivers/net/hp100.c~dma_mask-drivers_net drivers/net/hp100.c
--- kj/drivers/net/hp100.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/hp100.c	2005-03-05 16:13:20.000000000 +0100
@@ -562,7 +562,7 @@ static int __devinit hp100_probe1(struct
 			 * Also, we can have EISA Busmaster cards (not tested),
 			 * so beware !!! - Jean II */
 			if((bus == HP100_BUS_PCI) &&
-			   (pci_set_dma_mask(pci_dev, 0xffffffff))) {
+			   (pci_set_dma_mask(pci_dev, DMA_32BIT_MASK))) {
 				/* Gracefully fallback to shared memory */
 				goto busmasterfail;
 			}
diff -puN drivers/net/ns83820.c~dma_mask-drivers_net drivers/net/ns83820.c
--- kj/drivers/net/ns83820.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/ns83820.c	2005-03-05 16:13:20.000000000 +0100
@@ -1841,9 +1841,9 @@ static int __devinit ns83820_init_one(st
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
--- kj/drivers/net/s2io.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/s2io.c	2005-03-05 16:13:20.000000000 +0100
@@ -4615,19 +4615,19 @@ s2io_init_nic(struct pci_dev *pdev, cons
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
diff -puN drivers/net/sk98lin/skge.c~dma_mask-drivers_net drivers/net/sk98lin/skge.c
--- kj/drivers/net/sk98lin/skge.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/sk98lin/skge.c	2005-03-05 16:13:20.000000000 +0100
@@ -4912,8 +4912,8 @@ static int __devinit skge_probe_one(stru
 		goto out;
  
 	/* Configure DMA attributes. */
-	if (pci_set_dma_mask(pdev, (u64) 0xffffffffffffffffULL) &&
-	    pci_set_dma_mask(pdev, (u64) 0xffffffff))
+	if (pci_set_dma_mask(pdev, DMA_64BIT_MASK) &&
+	    pci_set_dma_mask(pdev, DMA_32BIT_MASK))
 		goto out_disable_device;
 
 
diff -puN drivers/net/sungem.c~dma_mask-drivers_net drivers/net/sungem.c
--- kj/drivers/net/sungem.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/sungem.c	2005-03-05 16:13:20.000000000 +0100
@@ -2816,10 +2816,10 @@ static int __devinit gem_init_one(struct
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
--- kj/drivers/net/tg3.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/tg3.c	2005-03-05 16:13:20.000000000 +0100
@@ -8667,17 +8667,17 @@ static int __devinit tg3_init_one(struct
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
--- kj/drivers/net/tlan.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/tlan.c	2005-03-05 16:13:20.000000000 +0100
@@ -555,7 +555,7 @@ static int __devinit TLan_probe1(struct 
 
 		priv->adapter = &board_info[ent->driver_data];
 
-		rc = pci_set_dma_mask(pdev, 0xFFFFFFFF);
+		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (rc) {
 			printk(KERN_ERR "TLAN: No suitable PCI mapping available.\n");
 			goto err_out_free_dev;
diff -puN drivers/net/tulip/dmfe.c~dma_mask-drivers_net drivers/net/tulip/dmfe.c
--- kj/drivers/net/tulip/dmfe.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/tulip/dmfe.c	2005-03-05 16:13:20.000000000 +0100
@@ -354,7 +354,7 @@ static int __devinit dmfe_init_one (stru
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	if (pci_set_dma_mask(pdev, 0xffffffff)) {
+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 		printk(KERN_WARNING DRV_NAME ": 32-bit PCI DMA not available.\n");
 		err = -ENODEV;
 		goto err_out_free;
diff -puN drivers/net/tulip/winbond-840.c~dma_mask-drivers_net drivers/net/tulip/winbond-840.c
--- kj/drivers/net/tulip/winbond-840.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/tulip/winbond-840.c	2005-03-05 16:13:20.000000000 +0100
@@ -394,7 +394,7 @@ static int __devinit w840_probe1 (struct
 
 	irq = pdev->irq;
 
-	if (pci_set_dma_mask(pdev,0xFFFFffff)) {
+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 		printk(KERN_WARNING "Winbond-840: Device %s disabled due to DMA limitations.\n",
 		       pci_name(pdev));
 		return -EIO;
diff -puN drivers/net/via-rhine.c~dma_mask-drivers_net drivers/net/via-rhine.c
--- kj/drivers/net/via-rhine.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/via-rhine.c	2005-03-05 16:13:20.000000000 +0100
@@ -740,7 +740,7 @@ static int __devinit rhine_init_one(stru
 		goto err_out;
 
 	/* this should always be supported */
-	rc = pci_set_dma_mask(pdev, 0xffffffff);
+	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if (rc) {
 		printk(KERN_ERR "32-bit PCI DMA addresses not supported by "
 		       "the card!?\n");
diff -puN drivers/net/wan/wanxl.c~dma_mask-drivers_net drivers/net/wan/wanxl.c
--- kj/drivers/net/wan/wanxl.c~dma_mask-drivers_net	2005-03-05 16:13:20.000000000 +0100
+++ kj-domen/drivers/net/wan/wanxl.c	2005-03-05 16:13:20.000000000 +0100
@@ -630,8 +630,8 @@ static int __devinit wanxl_pci_init_one(
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
