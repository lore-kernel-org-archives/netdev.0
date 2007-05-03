From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 5/16][BNX2]: Save PCI state during suspend.
Date: Thu, 03 May 2007 00:29:19 -0700
Message-ID: <1178177359.4909.69.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1385 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161148AbXECGmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:42:20 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Save PCI state during suspend.

This is needed to save the MSI state which will be lost during
suspend.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index cffdec3..89681b3 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6172,6 +6172,7 @@ bnx2_suspend(struct pci_dev *pdev, pm_message_t state)
 		reset_code = BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL;
 	bnx2_reset_chip(bp, reset_code);
 	bnx2_free_skbs(bp);
+	pci_save_state(pdev);
 	bnx2_set_power_state(bp, pci_choose_state(pdev, state));
 	return 0;
 }
@@ -6185,6 +6186,7 @@ bnx2_resume(struct pci_dev *pdev)
 	if (!netif_running(dev))
 		return 0;
 
+	pci_restore_state(pdev);
 	bnx2_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
 	bnx2_init_nic(bp);


