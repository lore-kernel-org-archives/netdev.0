From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next] cxgb4: remove a bogus PCI function number check
Date: Thu, 30 Sep 2010 12:17:12 -0700
Message-ID: <1285874232-1554-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21248 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756278Ab0I3TYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 15:24:13 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o8UJOCph031116
	for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 12:24:12 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove a bogus PCI function number check from the driver's .remove
method that causes pci_release_regions not to be called for function 0
if additional functions are attached and one of them is used as primary.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 4fb08e3..22169a7 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3863,7 +3863,7 @@ static void __devexit remove_one(struct pci_dev *pdev)
 		pci_disable_device(pdev);
 		pci_release_regions(pdev);
 		pci_set_drvdata(pdev, NULL);
-	} else if (PCI_FUNC(pdev->devfn) > 0)
+	} else
 		pci_release_regions(pdev);
 }
 
-- 
1.5.4

