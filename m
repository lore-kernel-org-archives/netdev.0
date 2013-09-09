From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] mwifiex: Remove casting the return value which is a void
 pointer
Date: Mon, 09 Sep 2013 14:26:51 +0900
Message-ID: <004d01cead1d$3058dcf0$910a96d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	'David Miller' <davem@davemloft.net>,
	'Bing Zhao' <bzhao@marvell.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'John W. Linville'" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:58556 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176Ab3IIF0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 01:26:53 -0400
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Casting the return value which is a void pointer is redundant.
The conversion from void pointer to any other pointer type is
guaranteed by the C programming language.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wireless/mwifiex/pcie.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
index 52da8ee..33fa943 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -93,7 +93,7 @@ static int mwifiex_pcie_suspend(struct device *dev)
 	struct pci_dev *pdev = to_pci_dev(dev);
 
 	if (pdev) {
-		card = (struct pcie_service_card *) pci_get_drvdata(pdev);
+		card = pci_get_drvdata(pdev);
 		if (!card || !card->adapter) {
 			pr_err("Card or adapter structure is not valid\n");
 			return 0;
@@ -128,7 +128,7 @@ static int mwifiex_pcie_resume(struct device *dev)
 	struct pci_dev *pdev = to_pci_dev(dev);
 
 	if (pdev) {
-		card = (struct pcie_service_card *) pci_get_drvdata(pdev);
+		card = pci_get_drvdata(pdev);
 		if (!card || !card->adapter) {
 			pr_err("Card or adapter structure is not valid\n");
 			return 0;
@@ -2037,7 +2037,7 @@ static irqreturn_t mwifiex_pcie_interrupt(int irq, void *context)
 		goto exit;
 	}
 
-	card = (struct pcie_service_card *) pci_get_drvdata(pdev);
+	card = pci_get_drvdata(pdev);
 	if (!card || !card->adapter) {
 		pr_debug("info: %s: card=%p adapter=%p\n", __func__, card,
 			 card ? card->adapter : NULL);
-- 
1.7.10.4
