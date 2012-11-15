From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/4] tg3: Set 10_100_ONLY flag for additional
 10/100 Mbps devices
Date: Wed, 14 Nov 2012 16:44:26 -0800
Message-ID: <1352940269-23821-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4034 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932299Ab2KOAa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 19:30:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Nayak Sujir <nsujir@broadcom.com>

- Also refactor the conditional to use the existing tg3_pci_tbl array.
- Set flags in the driver_data field of the pci_device_id structure to
identify these devices.
- Add PCI_DEVICE_SUB() to pci.h to declare PCI 4-part IDs to match these
devices.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   87 ++++++++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/tg3.h |    5 ++
 include/linux/pci.h                 |   14 ++++++
 3 files changed, 79 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 038ce02..8d4581b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -226,6 +226,9 @@ static int tg3_debug = -1;	/* -1 == use TG3_DEF_MSG_ENABLE as value */
 module_param(tg3_debug, int, 0);
 MODULE_PARM_DESC(tg3_debug, "Tigon3 bitmapped debugging message enable value");
 
+#define TG3_DRV_DATA_FLAG_10_100_ONLY	0x0001
+#define TG3_DRV_DATA_FLAG_5705_10_100	0x0002
+
 static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5700)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5701)},
@@ -245,20 +248,28 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5782)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5788)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5789)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901_2)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY |
+			TG3_DRV_DATA_FLAG_5705_10_100},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901_2),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY |
+			TG3_DRV_DATA_FLAG_5705_10_100},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5704S_2)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705F)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705F),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY |
+			TG3_DRV_DATA_FLAG_5705_10_100},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5721)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5722)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751M)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751F)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751F),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5752)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5752M)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5753)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5753M)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5753F)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5753F),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5754)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5754M)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5755)},
@@ -266,8 +277,13 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5756)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5786)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787)},
+	{PCI_DEVICE_SUB(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5787M,
+			PCI_VENDOR_ID_LENOVO,
+			TG3PCI_SUBDEVICE_ID_LENOVO_5787M),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787M)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787F)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787F),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5714)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5714S)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5715)},
@@ -286,9 +302,16 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5761SE)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5785_G)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5785_F)},
+	{PCI_DEVICE_SUB(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57780,
+			PCI_VENDOR_ID_AI, TG3PCI_SUBDEVICE_ID_ACER_57780_A),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
+	{PCI_DEVICE_SUB(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57780,
+			PCI_VENDOR_ID_AI, TG3PCI_SUBDEVICE_ID_ACER_57780_B),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57780)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57760)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57790)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57790),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57788)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5717)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5717_C)},
@@ -297,8 +320,10 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57785)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57761)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57765)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57791)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57791),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795),
+	 .driver_data = TG3_DRV_DATA_FLAG_10_100_ONLY},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5719)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5720)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57762)},
@@ -14466,7 +14491,30 @@ static void __devinit tg3_detect_asic_rev(struct tg3 *tp, u32 misc_ctrl_reg)
 		tg3_flag_set(tp, 5705_PLUS);
 }
 
-static int __devinit tg3_get_invariants(struct tg3 *tp)
+static bool tg3_10_100_only_device(struct tg3 *tp,
+				   const struct pci_device_id *ent)
+{
+	u32 grc_misc_cfg = tr32(GRC_MISC_CFG) & GRC_MISC_CFG_BOARD_ID_MASK;
+
+	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 &&
+	    (grc_misc_cfg == 0x8000 || grc_misc_cfg == 0x4000)) ||
+	    (tp->phy_flags & TG3_PHYFLG_IS_FET))
+		return true;
+
+	if (ent->driver_data & TG3_DRV_DATA_FLAG_10_100_ONLY) {
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+			if (ent->driver_data & TG3_DRV_DATA_FLAG_5705_10_100)
+				return true;
+		} else {
+			return true;
+		}
+	}
+
+	return false;
+}
+
+static int __devinit tg3_get_invariants(struct tg3 *tp,
+					const struct pci_device_id *ent)
 {
 	u32 misc_ctrl_reg;
 	u32 pci_state_reg, grc_misc_cfg;
@@ -15145,22 +15193,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	else
 		tp->mac_mode = 0;
 
-	/* these are limited to 10/100 only */
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 &&
-	     (grc_misc_cfg == 0x8000 || grc_misc_cfg == 0x4000)) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
-	     tp->pdev->vendor == PCI_VENDOR_ID_BROADCOM &&
-	     (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5901 ||
-	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5901_2 ||
-	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5705F)) ||
-	    (tp->pdev->vendor == PCI_VENDOR_ID_BROADCOM &&
-	     (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5751F ||
-	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5753F ||
-	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5787F)) ||
-	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57790 ||
-	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57791 ||
-	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57795 ||
-	    (tp->phy_flags & TG3_PHYFLG_IS_FET))
+	if (tg3_10_100_only_device(tp, ent))
 		tp->phy_flags |= TG3_PHYFLG_10_100_ONLY;
 
 	err = tg3_phy_probe(tp);
@@ -16039,7 +16072,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->netdev_ops = &tg3_netdev_ops;
 	dev->irq = pdev->irq;
 
-	err = tg3_get_invariants(tp);
+	err = tg3_get_invariants(tp, ent);
 	if (err) {
 		dev_err(&pdev->dev,
 			"Problem fetching invariants of chip, aborting\n");
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index b3c2bf2..6ff9964 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -44,6 +44,7 @@
 #define  TG3PCI_DEVICE_TIGON3_5761S	 0x1688
 #define  TG3PCI_DEVICE_TIGON3_5761SE	 0x1689
 #define  TG3PCI_DEVICE_TIGON3_57780	 0x1692
+#define  TG3PCI_DEVICE_TIGON3_5787M	 0x1693
 #define  TG3PCI_DEVICE_TIGON3_57760	 0x1690
 #define  TG3PCI_DEVICE_TIGON3_57790	 0x1694
 #define  TG3PCI_DEVICE_TIGON3_57788	 0x1691
@@ -96,6 +97,10 @@
 #define TG3PCI_SUBDEVICE_ID_COMPAQ_NC7780_2	0x0099
 #define TG3PCI_SUBVENDOR_ID_IBM			PCI_VENDOR_ID_IBM
 #define TG3PCI_SUBDEVICE_ID_IBM_5703SAX2	0x0281
+#define TG3PCI_SUBDEVICE_ID_ACER_57780_A	0x0601
+#define TG3PCI_SUBDEVICE_ID_ACER_57780_B	0x0612
+#define TG3PCI_SUBDEVICE_ID_LENOVO_5787M	0x3056
+
 /* 0x30 --> 0x64 unused */
 #define TG3PCI_MSI_DATA			0x00000064
 /* 0x66 --> 0x68 unused */
diff --git a/include/linux/pci.h b/include/linux/pci.h
index ee21795..9cbd670 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -604,6 +604,20 @@ struct pci_driver {
 	.subvendor = PCI_ANY_ID, .subdevice = PCI_ANY_ID
 
 /**
+ * PCI_DEVICE_SUB - macro used to describe a specific pci device with subsystem
+ * @vend: the 16 bit PCI Vendor ID
+ * @dev: the 16 bit PCI Device ID
+ * @subvend: the 16 bit PCI Subvendor ID
+ * @subdev: the 16 bit PCI Subdevice ID
+ *
+ * This macro is used to create a struct pci_device_id that matches a
+ * specific device with subsystem information.
+ */
+#define PCI_DEVICE_SUB(vend, dev, subvend, subdev) \
+	.vendor = (vend), .device = (dev), \
+	.subvendor = (subvend), .subdevice = (subdev)
+
+/**
  * PCI_DEVICE_CLASS - macro used to describe a specific pci device class
  * @dev_class: the class, subclass, prog-if triple for this device
  * @dev_class_mask: the class mask for this device
-- 
1.7.1
