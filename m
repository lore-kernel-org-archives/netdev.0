From: Somnath Kotur <Somnath.Kotur@emulex.com>
Subject: [PATCH net-next 5/5] be2net: Fix EEH error reset before a flash dump completes
Date: Thu, 26 Apr 2012 19:59:47 +0530
Message-ID: <41027429-3be4-408f-9831-27a362d7f136@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>,
	Sathya Perla <Sathya.Perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:47292 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751506Ab2DZOj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 10:39:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>

An EEH error can cause the FW to trigger a flash debug dump.
Resetting the card while flash dump is in progress can cause it not to recover.
Wait for it to finish before letting EEH flow to reset the card.

Signed-off-by: Sathya Perla <Sathya.Perla@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 602ba6c..435e2ed 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3830,6 +3830,11 @@ static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 
 	pci_disable_device(pdev);
 
+	/* The error could cause the FW to trigger a flash debug dump.
+	 * Resetting the card while flash dump is in progress
+	 * can cause it not to recover; wait for it to finish
+	 */
+	ssleep(30);
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
-- 
1.5.6.1
