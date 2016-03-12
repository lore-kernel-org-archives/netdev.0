From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 2/3] of_mdio: use IS_ERR_OR_NULL()
Date: Sun, 13 Mar 2016 00:34:02 +0300
Message-ID: <2638820.ej0i0xi4Er@wasted.cogentembedded.com>
References: <2682275.WNlbxTfNal@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:34494 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbcCLVeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 16:34:07 -0500
Received: by mail-lb0-f180.google.com with SMTP id xr8so190960205lbb.1
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 13:34:05 -0800 (PST)
In-Reply-To: <2682275.WNlbxTfNal@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR_OR_NULL() is open coded in of_mdiobus_register_phy(), so just call
it directly...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

---
Changes in version 2:
- removed the of_mdiobus_register_device() hunk;
- added the "Reviewed-by:" tag.

 drivers/of/of_mdio.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/of/of_mdio.c
===================================================================
--- net-next.orig/drivers/of/of_mdio.c
+++ net-next/drivers/of/of_mdio.c
@@ -56,7 +56,7 @@ static int of_mdiobus_register_phy(struc
 		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
 	else
 		phy = get_phy_device(mdio, addr, is_c45);
-	if (!phy || IS_ERR(phy))
+	if (IS_ERR_OR_NULL(phy))
 		return 1;
 
 	rc = irq_of_parse_and_map(child, 0);
