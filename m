From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/3] net: wireless: iwlegacy: add CONFIG_PM_SLEEP to
 suspend/resume functions
Date: Tue, 26 Mar 2013 16:03:51 +0900
Message-ID: <001d01ce29f0$1267de90$37379bb0$%han@samsung.com>
References: <001b01ce29ef$f09cbf10$d1d63d30$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:29008 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab3CZHDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 03:03:53 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MK900EYFAA4S9O0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 26 Mar 2013 16:03:52 +0900 (KST)
In-reply-to: <001b01ce29ef$f09cbf10$d1d63d30$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CONFIG_PM_SLEEP to suspend/resume functions to fix the following
build warning when CONFIG_PM_SLEEP is not selected. This is because
sleep PM callbacks defined by SIMPLE_DEV_PM_OPS are only used when
the CONFIG_PM_SLEEP is enabled.

drivers/net/wireless/iwlegacy/common.c:4894:1: warning: 'il_pci_suspend' defined but not used [-Wunused-function]
drivers/net/wireless/iwlegacy/common.c:4912:1: warning: 'il_pci_resume' defined but not used [-Wunused-function]

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wireless/iwlegacy/common.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index 01e2d2b..5b79819 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -4888,7 +4888,7 @@ il_add_beacon_time(struct il_priv *il, u32 base, u32 addon,
 }
 EXPORT_SYMBOL(il_add_beacon_time);
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 
 static int
 il_pci_suspend(struct device *device)
@@ -4939,7 +4939,7 @@ il_pci_resume(struct device *device)
 SIMPLE_DEV_PM_OPS(il_pm_ops, il_pci_suspend, il_pci_resume);
 EXPORT_SYMBOL(il_pm_ops);
 
-#endif /* CONFIG_PM */
+#endif /* CONFIG_PM_SLEEP */
 
 static void
 il_update_qos(struct il_priv *il)
-- 
1.7.2.5
