From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH 2/7] net: netcp: remove dead code from the driver
Date: Wed, 23 Sep 2015 13:37:06 -0400
Message-ID: <1443029831-22035-3-git-send-email-m-karicheri2@ti.com>
References: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nsekhar@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<w-kwok2@ti.com>, <davem@davemloft.net>,
	<gregkh@linuxfoundation.org>, <stable@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netcp_core is the first driver that will get initialized and the modules
(ethss, pa etc) will then get initialized. So the code at the end of
netcp_probe() that iterate over the modules is a dead code as the module
list will be always be empty. So remove this code.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 1a5aca5..c0bc4b9 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -2040,7 +2040,6 @@ static int netcp_probe(struct platform_device *pdev)
 	struct device_node *child, *interfaces;
 	struct netcp_device *netcp_device;
 	struct device *dev = &pdev->dev;
-	struct netcp_module *module;
 	int ret;
 
 	if (!node) {
@@ -2087,14 +2086,6 @@ static int netcp_probe(struct platform_device *pdev)
 	/* Add the device instance to the list */
 	list_add_tail(&netcp_device->device_list, &netcp_devices);
 
-	/* Probe & attach any modules already registered */
-	mutex_lock(&netcp_modules_lock);
-	for_each_netcp_module(module) {
-		ret = netcp_module_probe(netcp_device, module);
-		if (ret < 0)
-			dev_err(dev, "module(%s) probe failed\n", module->name);
-	}
-	mutex_unlock(&netcp_modules_lock);
 	return 0;
 
 probe_quit_interface:
-- 
1.9.1
