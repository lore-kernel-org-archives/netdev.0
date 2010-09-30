From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/8] tg3: Cleanup missing VPD partno section
Date: Thu, 30 Sep 2010 13:34:33 -0700
Message-ID: <1285878877-12148-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2220 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756619Ab0I3Uey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 16:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans up the default VPD partno section.  New entries for
5717 asic rev devices were also added.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   71 ++++++++++++++++++++++++++++------------------------
 1 files changed, 38 insertions(+), 33 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 93228aa..d76e718 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12527,44 +12527,49 @@ partno:
 
 out_not_found:
 	kfree(vpd_data);
-	if (!tp->board_part_number[0])
+	if (tp->board_part_number[0])
 		return;
 
 out_no_vpd:
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717)
+			strcpy(tp->board_part_number, "BCM5717");
+		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718)
+			strcpy(tp->board_part_number, "BCM5718");
+		else
+			goto nomatch;
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780) {
+		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57780)
+			strcpy(tp->board_part_number, "BCM57780");
+		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57760)
+			strcpy(tp->board_part_number, "BCM57760");
+		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57790)
+			strcpy(tp->board_part_number, "BCM57790");
+		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57788)
+			strcpy(tp->board_part_number, "BCM57788");
+		else
+			goto nomatch;
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) {
+		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57761)
+			strcpy(tp->board_part_number, "BCM57761");
+		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57765)
+			strcpy(tp->board_part_number, "BCM57765");
+		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57781)
+			strcpy(tp->board_part_number, "BCM57781");
+		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57785)
+			strcpy(tp->board_part_number, "BCM57785");
+		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57791)
+			strcpy(tp->board_part_number, "BCM57791");
+		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57795)
+			strcpy(tp->board_part_number, "BCM57795");
+		else
+			goto nomatch;
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		strcpy(tp->board_part_number, "BCM95906");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
-		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57780)
-		strcpy(tp->board_part_number, "BCM57780");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
-		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57760)
-		strcpy(tp->board_part_number, "BCM57760");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
-		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57790)
-		strcpy(tp->board_part_number, "BCM57790");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 &&
-		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57788)
-		strcpy(tp->board_part_number, "BCM57788");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
-		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57761)
-		strcpy(tp->board_part_number, "BCM57761");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
-		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57765)
-		strcpy(tp->board_part_number, "BCM57765");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
-		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57781)
-		strcpy(tp->board_part_number, "BCM57781");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
-		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57785)
-		strcpy(tp->board_part_number, "BCM57785");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
-		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57791)
-		strcpy(tp->board_part_number, "BCM57791");
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 &&
-		 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57795)
-		strcpy(tp->board_part_number, "BCM57795");
-	else
+	} else {
+nomatch:
 		strcpy(tp->board_part_number, "none");
+	}
 }
 
 static int __devinit tg3_fw_img_is_valid(struct tg3 *tp, u32 offset)
-- 
1.7.2.2


