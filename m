From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH] amd-xgbe: Fix unused suspend handlers build warning
Date: Sat, 26 Nov 2016 21:53:52 +0100
Message-ID: <20161126205352.19577-1-bp@alien8.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Tom Lendacky <thomas.lendacky@amd.com>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skyhub.de ([78.46.96.112]:51873 "EHLO mail.skyhub.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751325AbcKZUx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 26 Nov 2016 15:53:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Borislav Petkov <bp@suse.de>

Fix:

  drivers/net/ethernet/amd/xgbe/xgbe-main.c:835:12: warning: ‘xgbe_suspend’ defined
    but not used [-Wunused-function]
  drivers/net/ethernet/amd/xgbe/xgbe-main.c:855:12: warning: ‘xgbe_resume’ defined
    but not used [-Wunused-function]

I see it during randconfig builds here.

Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index e10e569c0d5f..2e8451b0a74a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -831,7 +831,7 @@ static int xgbe_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int xgbe_suspend(struct device *dev)
 {
 	struct net_device *netdev = dev_get_drvdata(dev);
@@ -876,7 +876,7 @@ static int xgbe_resume(struct device *dev)
 
 	return ret;
 }
-#endif /* CONFIG_PM */
+#endif /* CONFIG_PM_SLEEP */
 
 #ifdef CONFIG_ACPI
 static const struct acpi_device_id xgbe_acpi_match[] = {
-- 
2.10.0
