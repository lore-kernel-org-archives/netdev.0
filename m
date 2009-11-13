From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 19/20] tg3: Fix DIDs, Enable 5717 support
Date: Fri, 13 Nov 2009 15:03:51 -0800
Message-ID: <1258153432-7036-20-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4587 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932484AbZKMXE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the 5717 variant device ID enumerations and adds those
DIDs to the PCI ID table.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   10 ++++++----
 drivers/net/tg3.h |    7 +++----
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3ff2d40..b01ea2e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -241,6 +241,9 @@ static struct pci_device_id tg3_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57760)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57790)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57788)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5717)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5718)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5724)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -12702,10 +12705,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_USE_PROD_ID_REG) {
 		u32 prod_id_asic_rev;
 
-		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717C ||
-		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717S ||
-		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718C ||
-		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718S)
+		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717 ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 ||
+		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5724)
 			pci_read_config_dword(tp->pdev,
 					      TG3PCI_GEN2_PRODID_ASICREV,
 					      &prod_id_asic_rev);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 6be46ab..453a34f 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -46,10 +46,9 @@
 #define  TG3PCI_DEVICE_TIGON3_57788	 0x1691
 #define  TG3PCI_DEVICE_TIGON3_5785_G	 0x1699 /* GPHY */
 #define  TG3PCI_DEVICE_TIGON3_5785_F	 0x16a0 /* 10/100 only */
-#define  TG3PCI_DEVICE_TIGON3_5717C	 0x1655
-#define  TG3PCI_DEVICE_TIGON3_5717S	 0x1656
-#define  TG3PCI_DEVICE_TIGON3_5718C	 0x1665
-#define  TG3PCI_DEVICE_TIGON3_5718S	 0x1666
+#define  TG3PCI_DEVICE_TIGON3_5717	 0x1655
+#define  TG3PCI_DEVICE_TIGON3_5718	 0x1656
+#define  TG3PCI_DEVICE_TIGON3_5724	 0x165c
 /* 0x04 --> 0x64 unused */
 #define TG3PCI_MSI_DATA			0x00000064
 /* 0x66 --> 0x68 unused */
-- 
1.6.4.4


