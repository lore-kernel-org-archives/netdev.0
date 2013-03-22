From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 2/5] qlcnic: Log warning message for 83xx adapter in MSI mode.
Date: Fri, 22 Mar 2013 11:57:54 -0400
Message-ID: <1363967877-16812-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58767 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S933882Ab3CVQVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 12:21:07 -0400
In-Reply-To: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o 83xx adapter does not support MSI interrupts, display
  warning whenever module parameter is used to load driver
  in MSI mode.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index c6f9d5e..d980723 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1923,6 +1923,12 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			module_name(THIS_MODULE),
 			board_name, adapter->ahw->revision_id);
 	}
+
+	if (qlcnic_83xx_check(adapter) && !qlcnic_use_msi_x &&
+	    !!qlcnic_use_msi)
+		dev_warn(&pdev->dev,
+			 "83xx adapter do not support MSI interrupts\n");
+
 	err = qlcnic_setup_intr(adapter, 0);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to setup interrupt\n");
-- 
1.5.6
