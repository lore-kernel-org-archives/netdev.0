From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/2] tg3: Support 5717 C0
Date: Mon, 5 Nov 2012 16:26:29 -0800
Message-ID: <1352161590-1586-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2648 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932070Ab2KFAMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2012 19:12:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 5717C0 which is a 5720A0 with special bonds-out option.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    9 ++++++++-
 drivers/net/ethernet/broadcom/tg3.h |    2 ++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a8800ac..b7817ca 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -291,6 +291,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57790)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57788)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5717)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5717_C)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5718)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57781)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57785)},
@@ -14026,7 +14027,8 @@ out_not_found:
 
 out_no_vpd:
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
-		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717)
+		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717 ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717_C)
 			strcpy(tp->board_part_number, "BCM5717");
 		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718)
 			strcpy(tp->board_part_number, "BCM5718");
@@ -14397,6 +14399,7 @@ static void __devinit tg3_detect_asic_rev(struct tg3 *tp, u32 misc_ctrl_reg)
 		tg3_flag_set(tp, CPMU_PRESENT);
 
 		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717 ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717_C ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5719 ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5720)
@@ -14424,6 +14427,9 @@ static void __devinit tg3_detect_asic_rev(struct tg3 *tp, u32 misc_ctrl_reg)
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5752_A0_HW)
 		tp->pci_chip_rev_id = CHIPREV_ID_5752_A0;
 
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5717_C0)
+		tp->pci_chip_rev_id = CHIPREV_ID_5720_A0;
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
@@ -16013,6 +16019,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5761S ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5761SE ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717 ||
+	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717_C ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5719 ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5720) {
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index d9308c3..b3c2bf2 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -50,6 +50,7 @@
 #define  TG3PCI_DEVICE_TIGON3_5785_G	 0x1699 /* GPHY */
 #define  TG3PCI_DEVICE_TIGON3_5785_F	 0x16a0 /* 10/100 only */
 #define  TG3PCI_DEVICE_TIGON3_5717	 0x1655
+#define  TG3PCI_DEVICE_TIGON3_5717_C	 0x1665
 #define  TG3PCI_DEVICE_TIGON3_5718	 0x1656
 #define  TG3PCI_DEVICE_TIGON3_57781	 0x16b1
 #define  TG3PCI_DEVICE_TIGON3_57785	 0x16b5
@@ -149,6 +150,7 @@
 #define  CHIPREV_ID_57780_A0		 0x57780000
 #define  CHIPREV_ID_57780_A1		 0x57780001
 #define  CHIPREV_ID_5717_A0		 0x05717000
+#define  CHIPREV_ID_5717_C0		 0x05717200
 #define  CHIPREV_ID_57765_A0		 0x57785000
 #define  CHIPREV_ID_5719_A0		 0x05719000
 #define  CHIPREV_ID_5720_A0		 0x05720000
-- 
1.7.1
