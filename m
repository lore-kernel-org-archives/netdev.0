From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/3] net: ethernet: wiznet: add CONFIG_PM_SLEEP to
 suspend/resume functions
Date: Tue, 26 Mar 2013 16:02:55 +0900
Message-ID: <001b01ce29ef$f09cbf10$d1d63d30$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:43690 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab3CZHC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 03:02:57 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MK9007B0A8PPXS0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 26 Mar 2013 16:02:55 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CONFIG_PM_SLEEP to suspend/resume functions to fix the following
build warning when CONFIG_PM_SLEEP is not selected. This is because
sleep PM callbacks defined by SIMPLE_DEV_PM_OPS are only used when
the CONFIG_PM_SLEEP is enabled.

drivers/net/ethernet/wiznet/w5100.c:758:12: warning: 'w5100_suspend' defined but not used [-Wunused-function]
drivers/net/ethernet/wiznet/w5100.c:773:12: warning: 'w5100_resume' defined but not used [-Wunused-function]
drivers/net/ethernet/wiznet/w5300.c:670:12: warning: 'w5300_suspend' defined but not used [-Wunused-function]
drivers/net/ethernet/wiznet/w5300.c:685:12: warning: 'w5300_resume' defined but not used [-Wunused-function]

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/wiznet/w5100.c |    4 ++--
 drivers/net/ethernet/wiznet/w5300.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 545043c..a518dca 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -754,7 +754,7 @@ static int w5100_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int w5100_suspend(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
@@ -787,7 +787,7 @@ static int w5100_resume(struct device *dev)
 	}
 	return 0;
 }
-#endif /* CONFIG_PM */
+#endif /* CONFIG_PM_SLEEP */
 
 static SIMPLE_DEV_PM_OPS(w5100_pm_ops, w5100_suspend, w5100_resume);
 
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 7cbd0e6..6e00e3f 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -666,7 +666,7 @@ static int w5300_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int w5300_suspend(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
@@ -699,7 +699,7 @@ static int w5300_resume(struct device *dev)
 	}
 	return 0;
 }
-#endif /* CONFIG_PM */
+#endif /* CONFIG_PM_SLEEP */
 
 static SIMPLE_DEV_PM_OPS(w5300_pm_ops, w5300_suspend, w5300_resume);
 
-- 
1.7.2.5
