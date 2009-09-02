From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Disable PM capability
Date: Thu,  3 Sep 2009 00:51:20 +0900
Message-ID: <1251906680-5828-1-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:58433 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751339AbZIBPvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 11:51:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This chip may report existance of PM registers though they are not
supported.  Disable PM features by clearing pdev->pm_cap.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index d2ca47f..71e4482 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -909,6 +909,11 @@ static int __devinit tc35815_init_one(struct pci_dev *pdev,
 	lp = netdev_priv(dev);
 	lp->dev = dev;
 
+	/* This device may have PM registers but they are not supported. */
+	if (pdev->pm_cap) {
+		dev_info(&pdev->dev, "Disable PM\n");
+		pdev->pm_cap = 0;
+	}
 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
 	rc = pcim_enable_device(pdev);
 	if (rc)
-- 
1.5.6.5

