From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 4/9] bnx2: use pdev->pm_cap instead of pci_find_capability(..,PCI_CAP_ID_PM)
Date: Tue, 18 Jun 2013 16:12:37 +0800
Message-ID: <1371543157-14968-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>,
	<jiang.liu@huawei.com>, Yijing Wang <wangyijing@huawei.com>,
	Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pci core has been saved pm cap register offset by pdev->pm_cap in pci_pm_init()
in init path. So we can use pdev->pm_cap instead of using
pci_find_capability(pdev, PCI_CAP_ID_PM) for better performance and simplified code.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Michael Chan <mchan@broadcom.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/broadcom/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 5d20449..324709e 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8104,7 +8104,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	pci_set_master(pdev);
 
-	bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
+	bp->pm_cap = pdev->pm_cap;
 	if (bp->pm_cap == 0) {
 		dev_err(&pdev->dev,
 			"Cannot find power management capability, aborting\n");
-- 
1.7.1
