From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/3] qlge: Move reset from eeh io_resume to slot_reset.
Date: Wed,  3 Feb 2010 09:24:11 -0800
Message-ID: <1265217853-26959-2-git-send-email-ron.mercer@qlogic.com>
References: <1265217853-26959-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:1451 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932707Ab0BCRbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 12:31:09 -0500
In-Reply-To: <1265217853-26959-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Issue asic reset and verify functionality before continuing to the
resume call.  This allows proper error code to be returned in the case
the asic does not recover.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 5be3ae2..87ec720 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4717,6 +4717,12 @@ static pci_ers_result_t qlge_io_slot_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
+
+	if (ql_adapter_reset(qdev)) {
+		QPRINTK(qdev, DRV, ERR, "reset FAILED!\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
 	return PCI_ERS_RESULT_RECOVERED;
 }
 
@@ -4726,8 +4732,6 @@ static void qlge_io_resume(struct pci_dev *pdev)
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	int err = 0;
 
-	if (ql_adapter_reset(qdev))
-		QPRINTK(qdev, DRV, ERR, "reset FAILED!\n");
 	if (netif_running(ndev)) {
 		err = qlge_open(ndev);
 		if (err) {
-- 
1.6.0.2

