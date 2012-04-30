From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 4/5] be2net: Fix EEH error reset before a flash dump completes
Date: Mon, 30 Apr 2012 11:35:28 +0530
Message-ID: <25120d1d-8b69-418c-a598-11bd1cb38c75@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>,
	Sathya Perla <Sathya.Perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:42960 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751387Ab2D3GGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 02:06:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An EEH error can cause the FW to trigger a flash debug dump.
Resetting the card while flash dump is in progress can cause it not to recover.
Wait for it to finish before letting EEH flow to reset the card.

Signed-off-by: Sathya Perla <Sathya.Perla@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b7bc905..6d5d30b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3821,6 +3821,11 @@ static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 
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
