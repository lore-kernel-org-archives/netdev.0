From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/20][BNX2]: Save PCI state during suspend.
Date: Tue, 01 May 2007 18:14:22 -0700
Message-ID: <1178068462.4820.41.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3129 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946172AbXEBA1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 20:27:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Save PCI state during suspend.

This is needed to save the MSI state which will be lost during
suspend.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 971607c..8520967 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6281,6 +6281,7 @@ bnx2_suspend(struct pci_dev *pdev, pm_message_t state)
 		reset_code = BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL;
 	bnx2_reset_chip(bp, reset_code);
 	bnx2_free_skbs(bp);
+	pci_save_state(pdev);
 	bnx2_set_power_state(bp, pci_choose_state(pdev, state));
 	return 0;
 }
@@ -6294,6 +6295,7 @@ bnx2_resume(struct pci_dev *pdev)
 	if (!netif_running(dev))
 		return 0;
 
+	pci_restore_state(pdev);
 	bnx2_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
 	bnx2_init_nic(bp);


