From: Bin Liu <b-liu@ti.com>
Subject: [PATCH] net: ethernet: fix kernel OOPS when remove davinci_mdio module
Date: Thu, 30 Aug 2012 11:37:32 -0500
Message-ID: <1346344652-28487-1-git-send-email-b-liu@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <b-liu@ti.com>
To: <mugunthanvnm@ti.com>, <vaibhav.bedia@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

davinci mdio device is not unregistered from mdiobus when removing
the module, which causes BUG_ON() when free the device from mdiobus.

Calling mdiobus_unregister() before mdiobus_free() fixes the issue.

Signed-off-by: Bin Liu <b-liu@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 0c2fcdd..7de19a5 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -391,8 +391,10 @@ static int __devexit davinci_mdio_remove(struct platform_device *pdev)
 	struct device *dev = &pdev->dev;
 	struct davinci_mdio_data *data = dev_get_drvdata(dev);
 
-	if (data->bus)
+	if (data->bus) {
+		mdiobus_unregister(data->bus);
 		mdiobus_free(data->bus);
+	}
 
 	if (data->clk)
 		clk_put(data->clk);
-- 
1.7.0.4
