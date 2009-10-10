From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/8] qlge: Remove explicit setting of PCI Dev CTL reg.
Date: Sat, 10 Oct 2009 12:35:03 -0700
Message-ID: <1255203310-18114-2-git-send-email-ron.mercer@qlogic.com>
References: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	root <root@localhost.localdomain>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55225 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934754AbZJJTl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 15:41:58 -0400
In-Reply-To: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: root <root@localhost.localdomain>

Remove explicit setting of error reporting bits.

Signed-off-by: root <root@localhost.localdomain>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 48b45df..7a9dca8 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3868,8 +3868,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 				    struct net_device *ndev, int cards_found)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	int pos, err = 0;
-	u16 val16;
+	int err = 0;
 
 	memset((void *)qdev, 0, sizeof(*qdev));
 	err = pci_enable_device(pdev);
@@ -3881,19 +3880,6 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	qdev->ndev = ndev;
 	qdev->pdev = pdev;
 	pci_set_drvdata(pdev, ndev);
-	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (pos <= 0) {
-		dev_err(&pdev->dev, PFX "Cannot find PCI Express capability, "
-			"aborting.\n");
-		return pos;
-	} else {
-		pci_read_config_word(pdev, pos + PCI_EXP_DEVCTL, &val16);
-		val16 &= ~PCI_EXP_DEVCTL_NOSNOOP_EN;
-		val16 |= (PCI_EXP_DEVCTL_CERE |
-			  PCI_EXP_DEVCTL_NFERE |
-			  PCI_EXP_DEVCTL_FERE | PCI_EXP_DEVCTL_URRE);
-		pci_write_config_word(pdev, pos + PCI_EXP_DEVCTL, val16);
-	}
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
-- 
1.6.0.2

