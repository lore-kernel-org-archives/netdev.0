From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 03/15] drivers: net: cpsw: remove pm runtime calls from suspend callbacks
Date: Wed, 15 Jun 2016 14:55:51 +0300
Message-ID: <20160615115603.4897-4-grygorii.strashko@ti.com>
References: <20160615115603.4897-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:60492 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932737AbcFOL4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 07:56:24 -0400
In-Reply-To: <20160615115603.4897-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PM runtime is properly handled in cpsw_ndo_open/stop(), as result it
isn't required to duplicate these calls in .suspend()/.resume()
callbacks. Moreover, it might cause unnecessary RPM resume of CPSW
during System suspend in the case it's already suspended because
all ethX interfaces are down, before System suspend started.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c76f9db..ba81d4e 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2573,8 +2573,6 @@ static int cpsw_suspend(struct device *dev)
 			cpsw_ndo_stop(ndev);
 	}
 
-	pm_runtime_put_sync(&pdev->dev);
-
 	/* Select sleep pin state */
 	pinctrl_pm_select_sleep_state(&pdev->dev);
 
@@ -2587,8 +2585,6 @@ static int cpsw_resume(struct device *dev)
 	struct net_device	*ndev = platform_get_drvdata(pdev);
 	struct cpsw_priv	*priv = netdev_priv(ndev);
 
-	pm_runtime_get_sync(&pdev->dev);
-
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(&pdev->dev);
 
-- 
2.8.4
