From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/2] drivers: net: davinci_mdio: moving mdio resume earlier than cpsw ethernet driver
Date: Tue, 11 Jun 2013 15:32:04 +0530
Message-ID: <1370944925-11374-2-git-send-email-mugunthanvnm@ti.com>
References: <1370944925-11374-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:54501 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753741Ab3FKKAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 06:00:53 -0400
In-Reply-To: <1370944925-11374-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MDIO driver should resume before CPSW ethernet driver so that CPSW connect
to the phy and start tx/rx ethernet packets, changing the suspend/resume
apis with suspend_late/resume_early.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index b2275d1..74e56b3 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -476,8 +476,8 @@ static int davinci_mdio_resume(struct device *dev)
 }
 
 static const struct dev_pm_ops davinci_mdio_pm_ops = {
-	.suspend	= davinci_mdio_suspend,
-	.resume		= davinci_mdio_resume,
+	.suspend_late	= davinci_mdio_suspend,
+	.resume_early	= davinci_mdio_resume,
 };
 
 static const struct of_device_id davinci_mdio_of_mtable[] = {
-- 
1.7.9.5
