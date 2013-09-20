From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 2/8] tg3: Add support for new 577xx device ids
Date: Fri, 20 Sep 2013 16:46:56 -0700
Message-ID: <1379720822-6500-3-git-send-email-nsujir@broadcom.com>
References: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4809 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751562Ab3ITXrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 19:47:14 -0400
In-Reply-To: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for 57764, 57765, 57787, 57782 and 57786
devices.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 15 +++++++++++++--
 drivers/net/ethernet/broadcom/tg3.h |  3 +++
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d2bc391..0155ac3 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -337,6 +337,11 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5762)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5725)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5727)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57764)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57767)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57787)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57782)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57786)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -15760,9 +15765,12 @@ static void tg3_detect_asic_rev(struct tg3 *tp, u32 misc_ctrl_reg)
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5719 ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5720 ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57767 ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57764 ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5762 ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5725 ||
-		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5727)
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5727 ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57787)
 			reg = TG3PCI_GEN2_PRODID_ASICREV;
 		else if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_57781 ||
 			 tp->pdev->device == TG3PCI_DEVICE_TIGON3_57785 ||
@@ -17411,9 +17419,12 @@ static int tg3_init_one(struct pci_dev *pdev,
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5719 ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5720 ||
+	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57767 ||
+	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57764 ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5762 ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5725 ||
-	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5727) {
+	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5727 ||
+	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57787) {
 		tg3_flag_set(tp, ENABLE_APE);
 		tp->aperegs = pci_ioremap_bar(pdev, BAR_2);
 		if (!tp->aperegs) {
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index ddb8be1..e5249f8 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -68,6 +68,9 @@
 #define  TG3PCI_DEVICE_TIGON3_5762	 0x1687
 #define  TG3PCI_DEVICE_TIGON3_5725	 0x1643
 #define  TG3PCI_DEVICE_TIGON3_5727	 0x16f3
+#define  TG3PCI_DEVICE_TIGON3_57764	 0x1642
+#define  TG3PCI_DEVICE_TIGON3_57767	 0x1683
+#define  TG3PCI_DEVICE_TIGON3_57787	 0x1641
 /* 0x04 --> 0x2c unused */
 #define TG3PCI_SUBVENDOR_ID_BROADCOM		PCI_VENDOR_ID_BROADCOM
 #define TG3PCI_SUBDEVICE_ID_BROADCOM_95700A6	0x1644
-- 
1.8.1.4
