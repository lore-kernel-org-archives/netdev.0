From: xuyongjiande@163.com
Subject: [PATCH] qlcnic: Fix return value in qlcnic_probe()
Date: Tue, 30 Dec 2014 16:03:46 +0800
Message-ID: <1419926626-26624-1-git-send-email-xuyongjiande@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yongjian Xu <xuyongjiande@gmail.com>
To: shahed.shaikh@qlogic.com, Dept-GELinuxNICDev@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yongjian Xu <xuyongjiande@gmail.com>

If the check of adapter fails and goes into the 'else' branch, the
return value 'err' should not still be zero.

Signed-off-by: Yongjian Xu <xuyongjiande@gmail.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1aa25b1..a95b604 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2603,6 +2603,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	} else {
 		dev_err(&pdev->dev,
 			"%s: failed. Please Reboot\n", __func__);
+		err = -ENODEV;
 		goto err_out_free_hw;
 	}
 
-- 
1.7.9.5
