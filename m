From: Wei Yongjun <weiyj_lk@163.com>
Subject: [PATCH -next] net: cpmac: fix error handling of cpmac_probe()
Date: Tue, 19 Jul 2016 12:37:53 +0000
Message-ID: <1468931873-19614-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>,
	Varka Bhadram <varkab@cdac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:59949 "EHLO m12-18.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752963AbcGSMid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 08:38:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing free_netdev() before return from function
cpmac_probe() in the error handling case.
This patch revert commit 0465be8f4f1d ("net: cpmac: fix in
releasing resources"), which changed to only free_netdev
while register_netdev failed.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/ti/cpmac.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index f86497c..cecfdaa 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1117,7 +1117,7 @@ static int cpmac_probe(struct platform_device *pdev)
 	mem = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
 	if (!mem) {
 		rc = -ENODEV;
-		goto out;
+		goto fail;
 	}
 
 	dev->irq = platform_get_irq_byname(pdev, "irq");
@@ -1145,7 +1145,7 @@ static int cpmac_probe(struct platform_device *pdev)
 			dev_err(&pdev->dev, "Could not attach to PHY\n");
 
 		rc = PTR_ERR(phydev);
-		goto out;
+		goto fail;
 	}
 
 	rc = register_netdev(dev);
@@ -1164,7 +1164,6 @@ static int cpmac_probe(struct platform_device *pdev)
 
 fail:
 	free_netdev(dev);
-out:
 	return rc;
 }
