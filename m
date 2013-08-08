From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 01/16] bnx2: clean up unnecessary MSI/MSI-X capability find
Date: Thu, 8 Aug 2013 21:02:22 +0800
Message-ID: <1375966942-2052-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hanjun Guo <guohanjun@huawei.com>, <jiang.liu@huawei.com>,
	Yijing Wang <wangyijing@huawei.com>,
	Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:8339 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757811Ab3HHNCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 09:02:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI core will initialize device MSI/MSI-X capability in
pci_msi_init_pci_dev(). So device driver should use
pci_dev->msi_cap/msix_cap to determine whether the device
support MSI/MSI-X instead of using
pci_find_capability(pci_dev, PCI_CAP_ID_MSI/MSIX).
Access to PCIe device config space again will consume more time.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Michael Chan <mchan@broadcom.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/broadcom/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 6a2de1d..7c408cd 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8170,13 +8170,13 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	if (BNX2_CHIP(bp) == BNX2_CHIP_5709 &&
 	    BNX2_CHIP_REV(bp) != BNX2_CHIP_REV_Ax) {
-		if (pci_find_capability(pdev, PCI_CAP_ID_MSIX))
+		if (pdev->msix_cap)
 			bp->flags |= BNX2_FLAG_MSIX_CAP;
 	}
 
 	if (BNX2_CHIP_ID(bp) != BNX2_CHIP_ID_5706_A0 &&
 	    BNX2_CHIP_ID(bp) != BNX2_CHIP_ID_5706_A1) {
-		if (pci_find_capability(pdev, PCI_CAP_ID_MSI))
+		if (pdev->msi_cap)
 			bp->flags |= BNX2_FLAG_MSI_CAP;
 	}
 
-- 
1.7.1
