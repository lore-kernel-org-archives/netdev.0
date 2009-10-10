From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/8] qlge: Set PCIE max read request size.
Date: Sat, 10 Oct 2009 12:35:04 -0700
Message-ID: <1255203310-18114-3-git-send-email-ron.mercer@qlogic.com>
References: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	root <root@localhost.localdomain>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55225 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934768AbZJJTmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 15:42:13 -0400
In-Reply-To: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: root <root@localhost.localdomain>

Signed-off-by: root <root@localhost.localdomain>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 7a9dca8..aeb0104 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3881,6 +3881,13 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	qdev->pdev = pdev;
 	pci_set_drvdata(pdev, ndev);
 
+	/* Set PCIe read request size */
+	err = pcie_set_readrq(pdev, 4096);
+	if (err) {
+		dev_err(&pdev->dev, "Set readrq failed.\n");
+		goto err_out;
+	}
+
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
 		dev_err(&pdev->dev, "PCI region request failed.\n");
-- 
1.6.0.2

