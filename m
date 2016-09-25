From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] net: hisilicon: mark symbols static where possible
Date: Sun, 25 Sep 2016 17:16:44 +0800
Message-ID: <1474795004-8743-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: yisen.zhuang@huawei.com, salil.mehta@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33872 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752727AbcIYJRA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 05:17:00 -0400
Received: by mail-pf0-f179.google.com with SMTP id l25so7451800pfb.1
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 02:16:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 2 warnings when building kernel with W=1:
drivers/net/ethernet/hisilicon/hisi_femac.c:943:5: warning: no previous prototype for 'hisi_femac_drv_suspend' [-Wmissing-prototypes]
drivers/net/ethernet/hisilicon/hisi_femac.c:960:5: warning: no previous prototype for 'hisi_femac_drv_resume' [-Wmissing-prototypes]

In fact, these two functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/hisilicon/hisi_femac.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hisi_femac.c b/drivers/net/ethernet/hisilicon/hisi_femac.c
index ca68e22..ced1859 100644
--- a/drivers/net/ethernet/hisilicon/hisi_femac.c
+++ b/drivers/net/ethernet/hisilicon/hisi_femac.c
@@ -940,8 +940,8 @@ static int hisi_femac_drv_remove(struct platform_device *pdev)
 }
 
 #ifdef CONFIG_PM
-int hisi_femac_drv_suspend(struct platform_device *pdev,
-			   pm_message_t state)
+static int hisi_femac_drv_suspend(struct platform_device *pdev,
+				  pm_message_t state)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct hisi_femac_priv *priv = netdev_priv(ndev);
@@ -957,7 +957,7 @@ int hisi_femac_drv_suspend(struct platform_device *pdev,
 	return 0;
 }
 
-int hisi_femac_drv_resume(struct platform_device *pdev)
+static int hisi_femac_drv_resume(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct hisi_femac_priv *priv = netdev_priv(ndev);
-- 
2.7.4
