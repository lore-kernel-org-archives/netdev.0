From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 2/2] drivers: net: davinci_mdio: restore mdio clk divider in mdio resume
Date: Tue, 11 Jun 2013 15:32:05 +0530
Message-ID: <1370944925-11374-3-git-send-email-mugunthanvnm@ti.com>
References: <1370944925-11374-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:43207 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753741Ab3FKKAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 06:00:55 -0400
In-Reply-To: <1370944925-11374-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During suspend resume cycle all the register data is lost, so MDIO
clock divier value gets reset. This patch restores the clock divider
value.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 74e56b3..c47f0db 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -459,15 +459,12 @@ static int davinci_mdio_suspend(struct device *dev)
 static int davinci_mdio_resume(struct device *dev)
 {
 	struct davinci_mdio_data *data = dev_get_drvdata(dev);
-	u32 ctrl;
 
 	pm_runtime_get_sync(data->dev);
 
 	spin_lock(&data->lock);
 	/* restart the scan state machine */
-	ctrl = __raw_readl(&data->regs->control);
-	ctrl |= CONTROL_ENABLE;
-	__raw_writel(ctrl, &data->regs->control);
+	__davinci_mdio_reset(data);
 
 	data->suspended = false;
 	spin_unlock(&data->lock);
-- 
1.7.9.5
