From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [IXBGE]: Compilation fix for ixgbe_main.c.
Date: Thu, 27 Mar 2008 14:39:17 +0300
Message-ID: <1206617957-32679-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, cramerj@intel.com,
	auke-jan.h.kok@intel.com, jeff@garzik.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:64206 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755479AbYC0Lio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 07:38:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under CONFIG_DCA the compilation is broken since the commit
bd0362dde080cef377d99fa5beb5c25308c29c73 (ixgbe: Add optional
DCA infrastructure).

IXGBE_SUCCESS is not defined anywhere, replace it with 0.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 drivers/net/ixgbe/ixgbe_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7ad2993..cb371a8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -367,7 +367,7 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 		/* Always use CB2 mode, difference is masked
 		 * in the CB driver. */
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
-		if (dca_add_requester(dev) == IXGBE_SUCCESS) {
+		if (dca_add_requester(dev) == 0) {
 			ixgbe_setup_dca(adapter);
 			break;
 		}
@@ -381,7 +381,7 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 		break;
 	}
 
-	return IXGBE_SUCCESS;
+	return 0;
 }
 
 #endif /* CONFIG_DCA */
@@ -3605,7 +3605,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_register;
 
 #ifdef CONFIG_DCA
-	if (dca_add_requester(&pdev->dev) == IXGBE_SUCCESS) {
+	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 		/* always use CB2 mode, difference is masked
 		 * in the CB driver */
-- 
1.5.3.rc5

