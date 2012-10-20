From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 09/14] be2net: Fix unnecessary delay in PCI EEH
Date: Sat, 20 Oct 2012 21:33:37 +0530
Message-ID: <6ec19d49-d421-4b32-8ae9-127488429f65@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:40025 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235Ab2JTQEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:04:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During PCI EEH, driver waits for all functions in the card.
Wait is needed only once per card. Fix is to wait only for the
first PCI function.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index cca8645..410834d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4201,9 +4201,13 @@ static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 
 	/* The error could cause the FW to trigger a flash debug dump.
 	 * Resetting the card while flash dump is in progress
-	 * can cause it not to recover; wait for it to finish
+	 * can cause it not to recover; wait for it to finish.
+	 * Wait only for first function as it is needed only once per
+	 * adapter.
 	 */
-	ssleep(30);
+	if (pdev->devfn == 0)
+		ssleep(30);
+
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
-- 
1.6.0.2
