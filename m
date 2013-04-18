From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v2 5/8] net: sh-eth: Add CONFIG_PM to definition of dev_pm_ops
Date: Thu, 18 Apr 2013 19:11:06 +0900
Message-ID: <1366279869-23387-5-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:64598 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967682Ab3DRKLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 06:11:31 -0400
Received: by mail-pa0-f53.google.com with SMTP id bh4so1480805pad.40
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 03:11:31 -0700 (PDT)
In-Reply-To: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 v2: no change.

 drivers/net/ethernet/renesas/sh_eth.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 7de0b0e..af8c225 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2772,6 +2772,7 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM
 static int sh_eth_runtime_nop(struct device *dev)
 {
 	/*
@@ -2785,17 +2786,21 @@ static int sh_eth_runtime_nop(struct device *dev)
 	return 0;
 }
 
-static struct dev_pm_ops sh_eth_dev_pm_ops = {
+static const struct dev_pm_ops sh_eth_dev_pm_ops = {
 	.runtime_suspend = sh_eth_runtime_nop,
 	.runtime_resume = sh_eth_runtime_nop,
 };
+#define SH_ETH_PM_OPS &sh_eth_dev_pm_ops
+#else
+#define SH_ETH_PM_OPS NULL
+#endif
 
 static struct platform_driver sh_eth_driver = {
 	.probe = sh_eth_drv_probe,
 	.remove = sh_eth_drv_remove,
 	.driver = {
 		   .name = CARDNAME,
-		   .pm = &sh_eth_dev_pm_ops,
+		   .pm = SH_ETH_PM_OPS,
 	},
 };
 
-- 
1.7.10.4
