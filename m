From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] mwiflex: avoid possible null pointer dereference
Date: Wed, 18 May 2016 01:16:01 +0200
Message-ID: <1463526961-12019-1-git-send-email-xypron.glpk@gmx.de>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not dereference card before checking against NULL value.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/wireless/marvell/mwifiex/pcie.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/pcie.c b/drivers/net/wireless/marvell/mwifiex/pcie.c
index 0c7937e..ae1f79e 100644
--- a/drivers/net/wireless/marvell/mwifiex/pcie.c
+++ b/drivers/net/wireless/marvell/mwifiex/pcie.c
@@ -2901,10 +2901,11 @@ static void mwifiex_unregister_dev(struct mwifiex_adapter *adapter)
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
2.1.4
