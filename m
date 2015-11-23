From: Saurabh Sengar <saurabh.truth@gmail.com>
Subject: [PATCH] drivers: net: xgene: optimizing the code
Date: Mon, 23 Nov 2015 19:02:15 +0530
Message-ID: <1448285535-4514-1-git-send-email-saurabh.truth@gmail.com>
Cc: Saurabh Sengar <saurabh.truth@gmail.com>
To: isubramanian@apm.com, kchudgar@apm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36596 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502AbbKWNcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 08:32:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch does the following:
1 .  remove unnecessary if, else condition
2 .  reduce one variable
3 .  change the return type of 2 functions to void as there return values
turn out to be 0 always after above changes

Signed-off-by: Saurabh Sengar <saurabh.truth@gmail.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 25 +++++++++---------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 991412c..6096d02 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1084,7 +1084,7 @@ static const struct net_device_ops xgene_ndev_ops = {
 };
 
 #ifdef CONFIG_ACPI
-static int xgene_get_port_id_acpi(struct device *dev,
+static void xgene_get_port_id_acpi(struct device *dev,
 				  struct xgene_enet_pdata *pdata)
 {
 	acpi_status status;
@@ -1097,24 +1097,19 @@ static int xgene_get_port_id_acpi(struct device *dev,
 		pdata->port_id = temp;
 	}
 
-	return 0;
+	return;
 }
 #endif
 
-static int xgene_get_port_id_dt(struct device *dev, struct xgene_enet_pdata *pdata)
+static void xgene_get_port_id_dt(struct device *dev, struct xgene_enet_pdata *pdata)
 {
 	u32 id = 0;
-	int ret;
 
-	ret = of_property_read_u32(dev->of_node, "port-id", &id);
-	if (ret) {
-		pdata->port_id = 0;
-		ret = 0;
-	} else {
-		pdata->port_id = id & BIT(0);
-	}
+	of_property_read_u32(dev->of_node, "port-id", &id);
 
-	return ret;
+	pdata->port_id = id & BIT(0);
+
+	return;
 }
 
 static int xgene_get_tx_delay(struct xgene_enet_pdata *pdata)
@@ -1209,13 +1204,11 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	}
 
 	if (dev->of_node)
-		ret = xgene_get_port_id_dt(dev, pdata);
+		xgene_get_port_id_dt(dev, pdata);
 #ifdef CONFIG_ACPI
 	else
-		ret = xgene_get_port_id_acpi(dev, pdata);
+		xgene_get_port_id_acpi(dev, pdata);
 #endif
-	if (ret)
-		return ret;
 
 	if (!device_get_mac_address(dev, ndev->dev_addr, ETH_ALEN))
 		eth_hw_addr_random(ndev);
-- 
1.9.1
