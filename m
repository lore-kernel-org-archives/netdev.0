From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] mwifiex: fix possible NULL dereference
Date: Mon, 11 Apr 2016 20:57:39 +0530
Message-ID: <1460388459-21090-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33413 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbcDKP1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 11:27:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>

We have a check for card just after dereferencing it. So if it is NULL
we have already dereferenced it before its check. Lets dereference it
after checking card for NULL.

Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
---
 drivers/net/wireless/marvell/mwifiex/pcie.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/pcie.c b/drivers/net/wireless/marvell/mwifiex/pcie.c
index edf8b07..84562d0 100644
--- a/drivers/net/wireless/marvell/mwifiex/pcie.c
+++ b/drivers/net/wireless/marvell/mwifiex/pcie.c
@@ -2884,10 +2884,11 @@ static void mwifiex_unregister_dev(struct mwifiex_adapter *adapter)
 {
 	struct pcie_service_card *card = adapter->card;
 	const struct mwifiex_pcie_card_reg *reg;
-	struct pci_dev *pdev = card->dev;
+	struct pci_dev *pdev;
 	int i;
 
 	if (card) {
+		pdev = card->dev;
 		if (card->msix_enable) {
 			for (i = 0; i < MWIFIEX_NUM_MSIX_VECTORS; i++)
 				synchronize_irq(card->msix_entries[i].vector);
-- 
1.9.1
