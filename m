From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 1/9] Bnx2x: remove redundant D0 power state set
Date: Tue, 18 Jun 2013 16:05:39 +0800
Message-ID: <1371542739-13552-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>,
	<jiang.liu@huawei.com>, Yijing Wang <wangyijing@huawei.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	<netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pci_enable_device() will set device power state to D0,
so it's no need to do it again in bnx2x_init_dev().
Also remove redundant PM Cap find code, because pci core
has been saved the pci device pm cap value.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b4c9dea..6ecd497 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11959,7 +11959,7 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 	}
 
 	if (IS_PF(bp)) {
-		bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
+		bp->pm_cap = pdev->pm_cap;
 		if (bp->pm_cap == 0) {
 			dev_err(&bp->pdev->dev,
 				"Cannot find power management capability, aborting\n");
@@ -12008,8 +12008,6 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 	}
 	BNX2X_DEV_INFO("me reg PF num: %d\n", bp->pf_num);
 
-	bnx2x_set_power_state(bp, PCI_D0);
-
 	/* clean indirect addresses */
 	pci_write_config_dword(bp->pdev, PCICFG_GRC_ADDRESS,
 			       PCICFG_VENDOR_ID_OFFSET);
-- 
1.7.1
