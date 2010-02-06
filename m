From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 2/6] DMFE: move pci ID definitions into pci_ids.h and clean up the code
Date: Sat,  6 Feb 2010 22:18:58 +0200
Message-ID: <1265487542-4447-3-git-send-email-maximlevitsky@gmail.com>
References: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>,
	Maxim Levitsky <maxim-levitsky@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f211.google.com ([209.85.220.211]:58911 "EHLO
	mail-fx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989Ab0BFUTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2010 15:19:17 -0500
In-Reply-To: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Maxim Levitsky <maxim-levitsky@gmail.com>
---
 drivers/net/tulip/dmfe.c |   53 +++++++++++++++++++++++++--------------------
 drivers/net/tulip/dmfe.h |   15 +++---------
 include/linux/pci_ids.h  |    6 +++++
 3 files changed, 39 insertions(+), 35 deletions(-)

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 158ffc2..ee93651 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -81,6 +81,7 @@
 #include <linux/spinlock.h>
 #include <linux/crc32.h>
 #include <linux/bitops.h>
+#include <linux/pci_ids.h>
 
 #include <asm/processor.h>
 #include <linux/io.h>
@@ -143,7 +144,7 @@ static int dmfe_open(struct net_device *dev)
 	db->PHY_reg4 = 0x1e0;
 
 	/* CR6 operation mode decision */
-	if (!chkmode || (db->chip_id == PCI_DM9132_ID) ||
+	if (!chkmode || (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9132) ||
 		(db->chip_revision >= 0x30)) {
 		db->cr6_data |= DMFE_TXTH_256;
 		db->cr0_data = CR0_DEFAULT;
@@ -234,7 +235,7 @@ static void dmfe_hardware_init(struct net_device *dev)
 
 	/* RESET Phyxcer Chip by GPR port bit 7 */
 	outl(0x180, ioaddr + DCR12);		/* Let bit 7 output port */
-	if (db->chip_id == PCI_DM9009_ID) {
+	if (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9009) {
 		outl(0x80, ioaddr + DCR12);	/* Issue RESET signal */
 		mdelay(300);			/* Delay 300 ms */
 	}
@@ -255,7 +256,7 @@ static void dmfe_hardware_init(struct net_device *dev)
 	dmfe_update_cr6(db->cr6_data, ioaddr);
 
 	/* Send setup frame */
-	if (db->chip_id == PCI_DM9132_ID)
+	if (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9132)
 		dm9132_id_table(dev, dev->mc_count);	/* DM9132 */
 	else
 		dmfe_send_filter_frame(dev, dev->mc_count); /* DM9102/DM9102A */
@@ -625,7 +626,7 @@ static void dmfe_set_filter_mode(struct net_device *dev)
 	}
 
 	DMFE_DBUG(0, "Set multicast address", dev->mc_count);
-	if (db->chip_id == PCI_DM9132_ID)
+	if (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9132)
 		dm9132_id_table(dev, dev->mc_count);	/* DM9132 */
 	else
 		dmfe_send_filter_frame(dev, dev->mc_count); /* DM9102/DM9102A */
@@ -653,7 +654,8 @@ static void dmfe_timer(unsigned long data)
 	/* Media mode process when Link OK before enter this route */
 	if (db->first_in_callback == 0) {
 		db->first_in_callback = 1;
-		if (db->chip_type && (db->chip_id == PCI_DM9102_ID)) {
+
+		if (db->chip_type && (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9102)) {
 			db->cr6_data &= ~0x40000;
 			dmfe_update_cr6(db->cr6_data, db->ioaddr);
 			phy_write(db->ioaddr,
@@ -706,14 +708,16 @@ static void dmfe_timer(unsigned long data)
 	}
 
 	/* Link status check, Dynamic media type change */
-	if (db->chip_id == PCI_DM9132_ID)
+	if (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9132)
 		tmp_cr12 = inb(db->ioaddr + DCR9 + 3);	/* DM9132 */
 	else
 		tmp_cr12 = inb(db->ioaddr + DCR12);	/* DM9102/DM9102A */
 
-	if (((db->chip_id == PCI_DM9102_ID) &&
+
+	if (((db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9102) &&
 		(db->chip_revision == 0x30)) ||
-		((db->chip_id == PCI_DM9132_ID) &&
+
+		((db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9132) &&
 		(db->chip_revision == 0x10))) {
 		/* DM9102A Chip */
 		if (tmp_cr12 & 2)
@@ -1111,7 +1115,7 @@ static u8 dmfe_sense_speed(struct dmfe_board_info *db)
 
 	if ((phy_mode & 0x24) == 0x24) {
 
-		if (db->chip_id == PCI_DM9132_ID)	/* DM9132 */
+		if (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9132)	/* DM9132 */
 			phy_mode = phy_read(db->ioaddr,
 				    db->phy_addr, 7, db->chip_id) & 0xf000;
 		else 				/* DM9102/DM9102A */
@@ -1164,7 +1168,7 @@ static void dmfe_set_phyxcer(struct dmfe_board_info *db)
 	dmfe_update_cr6(db->cr6_data, db->ioaddr);
 
 	/* DM9009 Chip: Phyxcer reg18 bit12=0 */
-	if (db->chip_id == PCI_DM9009_ID) {
+	if (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9009) {
 		phy_reg = phy_read(db->ioaddr,
 				   db->phy_addr, 18, db->chip_id) & ~0x1000;
 
@@ -1196,7 +1200,7 @@ static void dmfe_set_phyxcer(struct dmfe_board_info *db)
 			break;
 		}
 
-		if (db->chip_id == PCI_DM9009_ID)
+		if (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9009)
 			phy_reg &= 0x61;
 	}
 
@@ -1208,7 +1212,7 @@ static void dmfe_set_phyxcer(struct dmfe_board_info *db)
 	phy_write(db->ioaddr, db->phy_addr, 4, phy_reg, db->chip_id);
 
 	/* Restart Auto-Negotiation */
-	if (db->chip_type && (db->chip_id == PCI_DM9102_ID))
+	if (db->chip_type && (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9102))
 		phy_write(db->ioaddr, db->phy_addr, 0, 0x1800, db->chip_id);
 	if (!db->chip_type)
 		phy_write(db->ioaddr, db->phy_addr, 0, 0x1200, db->chip_id);
@@ -1265,7 +1269,7 @@ static void dmfe_process_mode(struct dmfe_board_info *db)
 
 			phy_write(db->ioaddr,
 				  db->phy_addr, 0, phy_reg, db->chip_id);
-			if (db->chip_type && (db->chip_id == PCI_DM9102_ID))
+			if (db->chip_type && (db->chip_id == PCI_DEVICE_ID_DAVICOM_DM9102))
 				mdelay(20);
 			phy_write(db->ioaddr,
 				  db->phy_addr, 0, phy_reg, db->chip_id);
@@ -1284,7 +1288,7 @@ static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,
 	u16 i;
 	unsigned long ioaddr;
 
-	if (chip_id == PCI_DM9132_ID) {
+	if (chip_id == PCI_DEVICE_ID_DAVICOM_DM9132) {
 		ioaddr = iobase + 0x80 + offset * 4;
 		outw(phy_data, ioaddr);
 	} else {
@@ -1335,7 +1339,7 @@ static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u32 chip_id)
 	u16 phy_data;
 	unsigned long ioaddr;
 
-	if (chip_id == PCI_DM9132_ID) {
+	if (chip_id == PCI_DEVICE_ID_DAVICOM_DM9132) {
 		/* DM9132 Chip */
 		ioaddr = iobase + 0x80 + offset * 4;
 		phy_data = inw(ioaddr);
@@ -1765,8 +1769,8 @@ static int __devinit dmfe_probe(struct pci_dev *pdev,
 	 *	tulip driver, except for early DM9100s.
 	 */
 #ifdef CONFIG_TULIP_DM910X
-	if ((ent->driver_data == PCI_DM9100_ID && pdev->revision >= 0x30) ||
-	    ent->driver_data == PCI_DM9102_ID) {
+	if ((pdev->device == PCI_DEVICE_ID_DAVICOM_DM9100 && pdev->revision >= 0x30) ||
+	    pdev->device == PCI_DEVICE_ID_DAVICOM_DM9102) {
 		struct device_node *dp = pci_device_to_OF_node(pdev);
 
 		if (dp && of_get_property(dp, "local-mac-address", NULL)) {
@@ -1801,6 +1805,7 @@ static int __devinit dmfe_probe(struct pci_dev *pdev,
 		goto err_out_disable;
 	}
 
+
 	if (pci_resource_len(pdev, 0) < (CHK_IO_SIZE(pdev))) {
 		printk(KERN_ERR DRV_NAME ": Allocated I/O size too small\n");
 		err = -ENODEV;
@@ -1841,7 +1846,7 @@ static int __devinit dmfe_probe(struct pci_dev *pdev,
 	db->buf_pool_start = db->buf_pool_ptr;
 	db->buf_pool_dma_start = db->buf_pool_dma_ptr;
 
-	db->chip_id = ent->driver_data;
+	db->chip_id = pdev->device;
 	db->ioaddr = pci_resource_start(pdev, 0);
 	db->chip_revision = pdev->revision;
 	db->wol_mode = 0;
@@ -1876,9 +1881,9 @@ static int __devinit dmfe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_out_free_buf;
 
-	printk(KERN_INFO "%s: Davicom DM%04lx at pci%s, %pM, irq %d.\n",
+	printk(KERN_INFO "%s: Davicom DM%04x at pci%s, %pM, irq %d.\n",
 	       dev->name,
-	       ent->driver_data >> 16,
+	       pdev->device,
 	       pci_name(pdev),
 	       dev->dev_addr,
 	       dev->irq);
@@ -2001,10 +2006,10 @@ static int dmfe_resume(struct pci_dev *pci_dev)
 
 
 static struct pci_device_id dmfe_pci_tbl[] = {
-	{ 0x1282, 0x9132, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9132_ID },
-	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9102_ID },
-	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9100_ID },
-	{ 0x1282, 0x9009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9009_ID },
+	{ PCI_VDEVICE(DAVICOM, PCI_DEVICE_ID_DAVICOM_DM9132) },
+	{ PCI_VDEVICE(DAVICOM, PCI_DEVICE_ID_DAVICOM_DM9102) },
+	{ PCI_VDEVICE(DAVICOM, PCI_DEVICE_ID_DAVICOM_DM9100) },
+	{ PCI_VDEVICE(DAVICOM, PCI_DEVICE_ID_DAVICOM_DM9009) },
 	{ 0, }
 };
 MODULE_DEVICE_TABLE(pci, dmfe_pci_tbl);
diff --git a/drivers/net/tulip/dmfe.h b/drivers/net/tulip/dmfe.h
index 363e822..3bd2d87 100644
--- a/drivers/net/tulip/dmfe.h
+++ b/drivers/net/tulip/dmfe.h
@@ -64,10 +64,6 @@
 #define DRV_VERSION	"1.36.4"
 #define DRV_RELDATE	"2002-01-17"
 
-#define PCI_DM9132_ID   0x91321282      /* Davicom DM9132 ID */
-#define PCI_DM9102_ID   0x91021282      /* Davicom DM9102 ID */
-#define PCI_DM9100_ID   0x91001282      /* Davicom DM9100 ID */
-#define PCI_DM9009_ID   0x90091282      /* Davicom DM9009 ID */
 
 #define DM9102_IO_SIZE  0x80
 #define DM9102A_IO_SIZE 0x100
@@ -152,14 +148,11 @@
 		udelay(5); \
 	} while (0);
 
-#define __CHK_IO_SIZE(pci_id, dev_rev) \
- ((((pci_id) == PCI_DM9132_ID) || ((dev_rev) >= 0x30)) ? \
-	DM9102A_IO_SIZE : DM9102_IO_SIZE)
-
-#define CHK_IO_SIZE(pci_dev) \
-	(__CHK_IO_SIZE(((pci_dev)->device << 16) | (pci_dev)->vendor, \
-	(pci_dev)->revision))
 
+#define CHK_IO_SIZE(pdev) \
+	((pdev)->device == PCI_DEVICE_ID_DAVICOM_DM9132 || \
+	 (pdev)->revision > 0x30 ? \
+	DM9102A_IO_SIZE : DM9102_IO_SIZE)
 
 /* Structure/enum declaration ------------------------------- */
 struct tx_desc {
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index cca8a04..3086715 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1416,6 +1416,12 @@
 #define PCI_DEVICE_ID_VORTEX_GDT6x11RP	0x0104
 #define PCI_DEVICE_ID_VORTEX_GDT6x21RP	0x0105
 
+#define PCI_VENDOR_ID_DAVICOM		0x1282
+#define PCI_DEVICE_ID_DAVICOM_DM9132	0x9132
+#define PCI_DEVICE_ID_DAVICOM_DM9102	0x9102
+#define PCI_DEVICE_ID_DAVICOM_DM9100	0x9100
+#define PCI_DEVICE_ID_DAVICOM_DM9009	0x9009
+
 #define PCI_VENDOR_ID_EF		0x111a
 #define PCI_DEVICE_ID_EF_ATM_FPGA	0x0000
 #define PCI_DEVICE_ID_EF_ATM_ASIC	0x0002
-- 
1.6.3.3

