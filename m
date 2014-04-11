From: Daniel J Blueman <daniel@quora.org>
Subject: [PATCH] Don't build unused suspend/resume functions not enabled
Date: Fri, 11 Apr 2014 16:14:26 +0800
Message-ID: <1397204066-7389-1-git-send-email-daniel@quora.org>
Cc: linux-kernel@vger.kernel.org, Daniel J Blueman <daniel@quora.org>
To: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_PM_SLEEP isn't enabled, bnx2_suspend/resume are unused; don't
build them when they aren't used.

Signed-off-by: Daniel J Blueman <daniel@quora.org>
---
 drivers/net/ethernet/broadcom/bnx2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index b14c606..617bfe6 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8578,6 +8578,7 @@ bnx2_remove_one(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
+#ifdef CONFIG_PM_SLEEP
 static int
 bnx2_suspend(struct device *device)
 {
@@ -8616,7 +8617,6 @@ bnx2_resume(struct device *device)
 	return 0;
 }
 
-#ifdef CONFIG_PM_SLEEP
 static SIMPLE_DEV_PM_OPS(bnx2_pm_ops, bnx2_suspend, bnx2_resume);
 #define BNX2_PM_OPS (&bnx2_pm_ops)
 
-- 
1.8.3.2
