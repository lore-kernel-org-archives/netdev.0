From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v3 6/9] net: sh-eth: Add CONFIG_PM to definition of dev_pm_ops
Date: Tue,  7 May 2013 14:17:52 +0900
Message-ID: <1367903875-32606-6-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	sergei.shtylyov@cogentembedded.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:42548 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757760Ab3EGFSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:18:24 -0400
Received: by mail-da0-f43.google.com with SMTP id u7so118287dae.2
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 22:18:23 -0700 (PDT)
In-Reply-To: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
V3:
  Fix "ERROR: Macros with complex values should be enclosed in parenthesis" by SH_ETH_PM_OPS.
V2:
  no change.
 drivers/net/ethernet/renesas/sh_eth.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 667c908..fe9ff35 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2771,6 +2771,7 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM
 static int sh_eth_runtime_nop(struct device *dev)
 {
 	/*
@@ -2784,17 +2785,21 @@ static int sh_eth_runtime_nop(struct device *dev)
 	return 0;
 }
 
-static struct dev_pm_ops sh_eth_dev_pm_ops = {
+static const struct dev_pm_ops sh_eth_dev_pm_ops = {
 	.runtime_suspend = sh_eth_runtime_nop,
 	.runtime_resume = sh_eth_runtime_nop,
 };
+#define SH_ETH_PM_OPS (&sh_eth_dev_pm_ops)
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
