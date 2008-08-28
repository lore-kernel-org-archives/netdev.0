From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: Remove workaround for chipset quirk
Date: Wed, 27 Aug 2008 21:57:30 -0700
Message-ID: <1219899450-7098-1-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org, Michael Brown <mbrown@fensystems.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:38697 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751127AbYH1E5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 00:57:32 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove chipset-specific quirk workaround; the workaround caused
unrecoverable DMA lockups when the driver was loaded following a
PXE boot.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
Signed-off-by: Michael Brown <mbrown@fensystems.co.uk>
---
 drivers/net/netxen/netxen_nic_main.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 59d6521..8f7669d 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -359,16 +359,6 @@ static void netxen_pcie_strap_init(struct netxen_adapter *adapter)
 	int i, pos;
 	struct pci_dev *pdev;
 
-	pdev = pci_get_device(0x1166, 0x0140, NULL);
-	if (pdev) {
-		pci_dev_put(pdev);
-		adapter->hw_read_wx(adapter,
-			NETXEN_PCIE_REG(PCIE_TGT_SPLIT_CHICKEN), &chicken, 4);
-		chicken |= 0x4000;
-		adapter->hw_write_wx(adapter,
-			NETXEN_PCIE_REG(PCIE_TGT_SPLIT_CHICKEN), &chicken, 4);
-	}
-
 	pdev = adapter->pdev;
 
 	adapter->hw_read_wx(adapter,
-- 
1.5.4.3

