From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH] net: davinci_mdio: Use of_mdiobus_register()
Date: Tue,  6 May 2014 17:18:12 +0200
Message-ID: <1399389492-32596-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Daniel Mack <zonque@gmail.com>
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:50948 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500AbaEFPSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:18:21 -0400
Received: by mail-ee0-f45.google.com with SMTP id d49so2504729eek.32
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 08:18:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_mdiobus_register() calls mdiobus_register() internally, so the
functionality is preserved. However, by calling the of_ variant, phy
nodes can be augmented with extra information.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 0cca9de..359d42c 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -38,6 +38,7 @@
 #include <linux/davinci_emac.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/of_mdio.h>
 #include <linux/pinctrl/consumer.h>
 
 /*
@@ -389,7 +390,7 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	}
 
 	/* register the mii bus */
-	ret = mdiobus_register(data->bus);
+	ret = of_mdiobus_register(data->bus, dev->of_node);
 	if (ret)
 		goto bail_out;
 
-- 
1.9.0
