From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/4] qlge: Clean up module parameter name.
Date: Wed, 11 Nov 2009 14:54:05 -0800
Message-ID: <1257980046-2420-4-git-send-email-ron.mercer@qlogic.com>
References: <1257980046-2420-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:24232 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759487AbZKKXAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 18:00:36 -0500
In-Reply-To: <1257980046-2420-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change it to match qlge_xxx convention.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index d2a4bbe..e2ee47d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -69,9 +69,9 @@ MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 #define MSIX_IRQ 0
 #define MSI_IRQ 1
 #define LEG_IRQ 2
-static int irq_type = MSIX_IRQ;
-module_param(irq_type, int, MSIX_IRQ);
-MODULE_PARM_DESC(irq_type, "0 = MSI-X, 1 = MSI, 2 = Legacy.");
+static int qlge_irq_type = MSIX_IRQ;
+module_param(qlge_irq_type, int, MSIX_IRQ);
+MODULE_PARM_DESC(qlge_irq_type, "0 = MSI-X, 1 = MSI, 2 = Legacy.");
 
 static struct pci_device_id qlge_pci_tbl[] __devinitdata = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8012)},
@@ -2870,7 +2870,7 @@ static void ql_enable_msix(struct ql_adapter *qdev)
 	int i, err;
 
 	/* Get the MSIX vectors. */
-	if (irq_type == MSIX_IRQ) {
+	if (qlge_irq_type == MSIX_IRQ) {
 		/* Try to alloc space for the msix struct,
 		 * if it fails then go to MSI/legacy.
 		 */
@@ -2878,7 +2878,7 @@ static void ql_enable_msix(struct ql_adapter *qdev)
 					    sizeof(struct msix_entry),
 					    GFP_KERNEL);
 		if (!qdev->msi_x_entry) {
-			irq_type = MSI_IRQ;
+			qlge_irq_type = MSI_IRQ;
 			goto msi;
 		}
 
@@ -2901,7 +2901,7 @@ static void ql_enable_msix(struct ql_adapter *qdev)
 			QPRINTK(qdev, IFUP, WARNING,
 				"MSI-X Enable failed, trying MSI.\n");
 			qdev->intr_count = 1;
-			irq_type = MSI_IRQ;
+			qlge_irq_type = MSI_IRQ;
 		} else if (err == 0) {
 			set_bit(QL_MSIX_ENABLED, &qdev->flags);
 			QPRINTK(qdev, IFUP, INFO,
@@ -2912,7 +2912,7 @@ static void ql_enable_msix(struct ql_adapter *qdev)
 	}
 msi:
 	qdev->intr_count = 1;
-	if (irq_type == MSI_IRQ) {
+	if (qlge_irq_type == MSI_IRQ) {
 		if (!pci_enable_msi(qdev->pdev)) {
 			set_bit(QL_MSI_ENABLED, &qdev->flags);
 			QPRINTK(qdev, IFUP, INFO,
@@ -2920,7 +2920,7 @@ msi:
 			return;
 		}
 	}
-	irq_type = LEG_IRQ;
+	qlge_irq_type = LEG_IRQ;
 	QPRINTK(qdev, IFUP, DEBUG, "Running with legacy interrupts.\n");
 }
 
-- 
1.6.0.2

