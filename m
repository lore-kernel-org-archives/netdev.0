From: Julia Lawall <julia.lawall@lip6.fr>
Subject: [PATCH 08/11 v2] net/fsl: use of_property_read_bool
Date: Fri, 5 Aug 2016 13:24:12 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1608051323170.2999@hadrien>
References: <1470387411-15879-1-git-send-email-Julia.Lawall@lip6.fr> <1470387411-15879-9-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:58483 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751799AbcHELYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 07:24:19 -0400
In-Reply-To: <1470387411-15879-9-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of_property_read_bool to check for the existence of a property.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression e1,e2,x;
@@
-	if (of_get_property(e1,e2,NULL))
-		x = true;
-	else
-		x = false;
+	x = of_property_read_bool(e1,e2);
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
v2: special case for propagating true and false

 drivers/net/ethernet/freescale/xgmac_mdio.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index 7b8fe86..e03b30c 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -271,11 +271,8 @@ static int xgmac_mdio_probe(struct platform_device *pdev)
 		goto err_ioremap;
 	}

-	if (of_get_property(pdev->dev.of_node,
-			    "little-endian", NULL))
-		priv->is_little_endian = true;
-	else
-		priv->is_little_endian = false;
+	priv->is_little_endian = of_property_read_bool(pdev->dev.of_node,
+						       "little-endian");

 	ret = of_mdiobus_register(bus, np);
 	if (ret) {
