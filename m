From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 5/5] qlge: Fix error exit for probe call.
Date: Tue, 29 Sep 2009 11:39:25 -0700
Message-ID: <1254249565-16381-6-git-send-email-ron.mercer@qlogic.com>
References: <1254249565-16381-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:8737 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448AbZI2SpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 14:45:16 -0400
In-Reply-To: <1254249565-16381-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index fbef305..c8a9efe 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3832,11 +3832,14 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 		return err;
 	}
 
+	qdev->ndev = ndev;
+	qdev->pdev = pdev;
+	pci_set_drvdata(pdev, ndev);
 	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (pos <= 0) {
 		dev_err(&pdev->dev, PFX "Cannot find PCI Express capability, "
 			"aborting.\n");
-		goto err_out;
+		return pos;
 	} else {
 		pci_read_config_word(pdev, pos + PCI_EXP_DEVCTL, &val16);
 		val16 &= ~PCI_EXP_DEVCTL_NOSNOOP_EN;
@@ -3849,7 +3852,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
 		dev_err(&pdev->dev, "PCI region request failed.\n");
-		goto err_out;
+		return err;
 	}
 
 	pci_set_master(pdev);
@@ -3867,7 +3870,6 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 		goto err_out;
 	}
 
-	pci_set_drvdata(pdev, ndev);
 	qdev->reg_base =
 	    ioremap_nocache(pci_resource_start(pdev, 1),
 			    pci_resource_len(pdev, 1));
@@ -3887,8 +3889,6 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 		goto err_out;
 	}
 
-	qdev->ndev = ndev;
-	qdev->pdev = pdev;
 	err = ql_get_board_info(qdev);
 	if (err) {
 		dev_err(&pdev->dev, "Register access failed.\n");
-- 
1.6.0.2

