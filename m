From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] convert wan/lmc to device model
Date: Mon, 22 Sep 2003 11:46:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030922114603.34f3a2f5.shemminger@osdl.org>
References: <20030916143627.51a08be0.shemminger@osdl.org>
	<3F6C92B3.3060603@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F6C92B3.3060603@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Okay, here is a patch to use pci_ids.h values.

> Um, this is majorly ugly.  I know you didn't create the CORRECT_xxx 
> constants... but let's not use them.  Either use the hex constants 
> directly, or update pci_ids.h and use the constants from there.


diff -Nru a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
--- a/drivers/net/wan/lmc/lmc_main.c	Mon Sep 22 11:45:18 2003
+++ b/drivers/net/wan/lmc/lmc_main.c	Mon Sep 22 11:45:18 2003
@@ -83,8 +83,10 @@
 static int LMC_PKT_BUF_SZ = 1542;
 
 static struct pci_device_id lmc_pci_tbl[] = {
-	{ CORRECT_VENDOR_ID, CORRECT_DEV_ID, PCI_VENDOR_LMC, PCI_ANY_ID },
-	{ CORRECT_VENDOR_ID, CORRECT_DEV_ID, PCI_ANY_ID, PCI_VENDOR_LMC },
+	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
+	  PCI_VENDOR_ID_LMC, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
+	  PCI_ANY_ID, PCI_VENDOR_ID_LMC },
 	{ 0 }
 };
 
@@ -921,26 +923,26 @@
      * the setting in the bois, seems to be version and arch dependent?
      * Fix the error, exchange the two values 
      */
-    if ((subdevice = pdev->subsystem_device) == PCI_VENDOR_LMC)
+    if ((subdevice = pdev->subsystem_device) == PCI_VENDOR_ID_LMC)
 	    subdevice = pdev->subsystem_vendor;
 
     switch (subdevice) {
-    case PCI_PRODUCT_LMC_HSSI:
+    case PCI_DEVICE_ID_LMC_HSSI:
         printk ("%s: LMC HSSI\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_HSSI;
         sc->lmc_media = &lmc_hssi_media;
         break;
-    case PCI_PRODUCT_LMC_DS3:
+    case PCI_DEVICE_ID_LMC_DS3:
         printk ("%s: LMC DS3\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_DS3;
         sc->lmc_media = &lmc_ds3_media;
         break;
-    case PCI_PRODUCT_LMC_SSI:
+    case PCI_DEVICE_ID_LMC_SSI:
         printk ("%s: LMC SSI\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_SSI;
         sc->lmc_media = &lmc_ssi_media;
         break;
-    case PCI_PRODUCT_LMC_T1:
+    case PCI_DEVICE_ID_LMC_T1:
         printk ("%s: LMC T1\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_T1;
         sc->lmc_media = &lmc_t1_media;
@@ -965,13 +967,13 @@
     AdapModelNum = (lmc_mii_readreg (sc, 0, 3) & 0x3f0) >> 4;
 
     if ((AdapModelNum == LMC_ADAP_T1
-         && subdevice == PCI_PRODUCT_LMC_T1) ||		/* detect LMC1200 */
+         && subdevice == PCI_DEVICE_ID_LMC_T1) ||	/* detect LMC1200 */
         (AdapModelNum == LMC_ADAP_SSI
-         && subdevice == PCI_PRODUCT_LMC_SSI) ||	/* detect LMC1000 */
+         && subdevice == PCI_DEVICE_ID_LMC_SSI) ||	/* detect LMC1000 */
         (AdapModelNum == LMC_ADAP_DS3
-         && subdevice == PCI_PRODUCT_LMC_DS3) ||	/* detect LMC5245 */
+         && subdevice == PCI_DEVICE_ID_LMC_DS3) ||	/* detect LMC5245 */
         (AdapModelNum == LMC_ADAP_HSSI
-         && subdevice == PCI_PRODUCT_LMC_HSSI))
+         && subdevice == PCI_DEVICE_ID_LMC_HSSI))
     {				/* detect LMC5200 */
 
     }
diff -Nru a/drivers/net/wan/lmc/lmc_var.h b/drivers/net/wan/lmc/lmc_var.h
--- a/drivers/net/wan/lmc/lmc_var.h	Mon Sep 22 11:45:18 2003
+++ b/drivers/net/wan/lmc/lmc_var.h	Mon Sep 22 11:45:18 2003
@@ -519,18 +519,7 @@
 #define TULIP_CMD_RECEIVEALL 0x40000000L
 #endif
 
-
-/* PCI register values */
-#define CORRECT_VENDOR_ID    0x1011
-#define CORRECT_DEV_ID       9
-
-#define PCI_VENDOR_LMC		0x1376
-#define PCI_PRODUCT_LMC_HSSI	0x0003
-#define PCI_PRODUCT_LMC_DS3	0x0004
-#define PCI_PRODUCT_LMC_SSI	0x0005
-#define PCI_PRODUCT_LMC_T1      0x0006
-
-/* Adapcter module number */
+/* Adapter module number */
 #define LMC_ADAP_HSSI           2
 #define LMC_ADAP_DS3            3
 #define LMC_ADAP_SSI            4
