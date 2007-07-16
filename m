From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 4/7][ATM]: [lanai] change VENDOR to DEVICE
Date: Mon, 16 Jul 2007 12:30:55 -0400
Message-ID: <200707161630.l6GGUtEq009321@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:47466 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759648AbXGPREp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 13:04:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ATM]: [lanai] change VENDOR to DEVICE

There were 2 bad named macros in pci_ids (LANAI 2 and IHB). Rename it to
DEVICE, because it's device id. Also some cleanup in the pci_device_id
table (use PCI_VDEVICE).

Cc: Mitchell Blank Jr <mitch@sfgoth.com>
Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Signed-off-by: chas williams <chas@cmf.nrl.navy.mil>

---
commit b7560ad591d645443595555766df2f2c687e9e65
tree fc9f8bdd2bf0f16de90cf9576220cff586ce4d8b
parent e9e4b3e9524fd445fcc06f56678a6b7f3d1d5f3a
author Jiri Slaby <jirislaby@gmail.com> Wed, 11 Jul 2007 12:26:48 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 11 Jul 2007 12:26:48 -0400

 drivers/atm/lanai.c     |   14 ++++----------
 include/linux/pci_ids.h |    4 ++--
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 09f477d..4e1fa50 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -246,8 +246,8 @@ struct lanai_vcc {
 };
 
 enum lanai_type {
-	lanai2	= PCI_VENDOR_ID_EF_ATM_LANAI2,
-	lanaihb	= PCI_VENDOR_ID_EF_ATM_LANAIHB
+	lanai2	= PCI_DEVICE_ID_EF_ATM_LANAI2,
+	lanaihb	= PCI_DEVICE_ID_EF_ATM_LANAIHB
 };
 
 struct lanai_dev_stats {
@@ -2631,14 +2631,8 @@ static int __devinit lanai_init_one(struct pci_dev *pci,
 }
 
 static struct pci_device_id lanai_pci_tbl[] = {
-	{
-		PCI_VENDOR_ID_EF, PCI_VENDOR_ID_EF_ATM_LANAI2,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0
-	},
-	{
-		PCI_VENDOR_ID_EF, PCI_VENDOR_ID_EF_ATM_LANAIHB,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0
-	},
+	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_LANAI2) },
+	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_LANAIHB) },
 	{ 0, }	/* terminal entry */
 };
 MODULE_DEVICE_TABLE(pci, lanai_pci_tbl);
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 75c4d4d..a260a94 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1383,8 +1383,8 @@
 #define PCI_VENDOR_ID_EF		0x111a
 #define PCI_DEVICE_ID_EF_ATM_FPGA	0x0000
 #define PCI_DEVICE_ID_EF_ATM_ASIC	0x0002
-#define PCI_VENDOR_ID_EF_ATM_LANAI2	0x0003
-#define PCI_VENDOR_ID_EF_ATM_LANAIHB	0x0005
+#define PCI_DEVICE_ID_EF_ATM_LANAI2	0x0003
+#define PCI_DEVICE_ID_EF_ATM_LANAIHB	0x0005
 
 #define PCI_VENDOR_ID_IDT		0x111d
 #define PCI_DEVICE_ID_IDT_IDT77201	0x0001
