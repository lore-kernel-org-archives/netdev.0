From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 12/19] niu: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 12:45:44 -0500
Message-ID: <1309196744-16123-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:34276 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab1F0Rpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:45:51 -0400
Received: by pvg12 with SMTP id 12so2992727pvg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:45:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  It will
remove an unnecessary search in the PCI configuration space if this
value is referenced instead of reacquiring it.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/niu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 1c7b790..cd6c231 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -9797,7 +9797,7 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 		goto err_out_disable_pdev;
 	}
 
-	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	pos = pci_pcie_cap(pdev);
 	if (pos <= 0) {
 		dev_err(&pdev->dev, "Cannot find PCI Express capability, aborting\n");
 		goto err_out_free_res;
-- 
1.7.5.4

