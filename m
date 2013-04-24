From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 5/5] bnx2x: Allow recovery from second slot
 reset
Date: Wed, 24 Apr 2013 14:45:02 +0300
Message-ID: <1366803902-17870-6-git-send-email-yuvalmin@broadcom.com>
References: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1044 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838Ab3DXMqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 08:46:39 -0400
In-Reply-To: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of PCIe Advanced Error Reporting flow, if a fatal PCI error occurs,
the AER driver will cause bnx2x's PCI-core to reset. The driver's PCI error
handlers will in turn restore the PCI configuration space values by calling
`pci_restore_state'.

However, as bnx2x does not save the PCI configuration after restoration,
An additional fatal PCI error will leave the function in an unstable state
until reboot, as the registers in the PCI configuration space will contain
reset values.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 4019465..927f83a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12813,6 +12813,7 @@ static pci_ers_result_t bnx2x_io_slot_reset(struct pci_dev *pdev)
 
 	pci_set_master(pdev);
 	pci_restore_state(pdev);
+	pci_save_state(pdev);
 
 	if (netif_running(dev))
 		bnx2x_set_power_state(bp, PCI_D0);
-- 
1.8.1.227.g44fe835
