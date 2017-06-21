From: Lokesh Vutla <lokeshvutla@ti.com>
Subject: [PATCH] drivers: net: cpsw-common: Fix reading of mac address for am43 SoCs
Date: Wed, 21 Jun 2017 14:12:04 +0530
Message-ID: <20170621084204.1512-1-lokeshvutla@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux netdev Mailing List <netdev@vger.kernel.org>,
        Tero Kristo <t-kristo@ti.com>, Sekhar Nori <nsekhar@ti.com>,
        Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
        Lokesh Vutla <lokeshvutla@ti.com>,
        Dave Gerlach <d-gerlach@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:60398 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752218AbdFUIp1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 04:45:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cpsw driver tries to get macid for am43xx SoCs using the compatible
ti,am4372. But not all variants of am43x uses this complatible like
epos evm uses ti,am438x. So use a generic compatible ti,am43 to get
macid for all am43 based platforms.

Reviewed-by: Dave Gerlach <d-gerlach@ti.com>
Signed-off-by: Lokesh Vutla <lokeshvutla@ti.com>
---
 drivers/net/ethernet/ti/cpsw-common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw-common.c b/drivers/net/ethernet/ti/cpsw-common.c
index 1562ab4151e1..56ba411421f0 100644
--- a/drivers/net/ethernet/ti/cpsw-common.c
+++ b/drivers/net/ethernet/ti/cpsw-common.c
@@ -90,7 +90,7 @@ int ti_cm_get_macid(struct device *dev, int slave, u8 *mac_addr)
 	if (of_device_is_compatible(dev->of_node, "ti,dm816-emac"))
 		return cpsw_am33xx_cm_get_macid(dev, 0x30, slave, mac_addr);
 
-	if (of_machine_is_compatible("ti,am4372"))
+	if (of_machine_is_compatible("ti,am43"))
 		return cpsw_am33xx_cm_get_macid(dev, 0x630, slave, mac_addr);
 
 	if (of_machine_is_compatible("ti,dra7"))
-- 
2.13.0
