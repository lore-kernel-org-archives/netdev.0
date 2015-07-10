From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next 3/9] be2net: remove redundant D0 power state set
Date: Fri, 10 Jul 2015 05:32:45 -0400
Message-ID: <1436520771-11656-4-git-send-email-sathya.perla@avagotech.com>
References: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56755 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753400AbbGJJ0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 05:26:33 -0400
In-Reply-To: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh Purayil <kalesh.purayil@avagotech.com>

pci_enable_device() call sets device power state to D0; there is no need
doing it again.

Signed-off-by: Kalesh AP <kalesh.purayil@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f21c56a..8b81e23 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5807,7 +5807,6 @@ static int be_pci_resume(struct pci_dev *pdev)
 	if (status)
 		return status;
 
-	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
 	status = be_resume(adapter);
@@ -5887,7 +5886,6 @@ static pci_ers_result_t be_eeh_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 
 	pci_set_master(pdev);
-	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
 	/* Check if card is ok and fw is ready */
-- 
2.4.1
