From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 1/2] net: ethernet: ti: cpsw: fix cpsw assignment in resume
Date: Thu,  9 Feb 2017 02:07:35 +0200
Message-ID: <1486598856-3512-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1486598856-3512-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        AStarikovskiy@topcon.com,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:33260 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751783AbdBIAHq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 19:07:46 -0500
Received: by mail-lf0-f44.google.com with SMTP id x1so91801111lff.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 16:07:42 -0800 (PST)
In-Reply-To: <1486598856-3512-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a copy-paste error, which hides breaking of resume
for CPSW driver: there was replaced netdev_priv() to ndev_to_cpsw(ndev)
in suspend, but left it unchanged in resume.

Fixes: 606f39939595a4d4540406bfc11f265b2036af6d
(ti: cpsw: move platform data and slaves info to cpsw_common)

Reported-by: Alexey Starikovskiy <AStarikovskiy@topcon.com>
Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 4d1c0c3..9714fab 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -3225,7 +3225,7 @@ static int cpsw_resume(struct device *dev)
 {
 	struct platform_device	*pdev = to_platform_device(dev);
 	struct net_device	*ndev = platform_get_drvdata(pdev);
-	struct cpsw_common	*cpsw = netdev_priv(ndev);
+	struct cpsw_common	*cpsw = ndev_to_cpsw(ndev);
 
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(dev);
-- 
2.7.4
