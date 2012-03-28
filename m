From: Kenth Eriksson <kenth.eriksson@transmode.com>
Subject: [PATCH 1/3] Fix non TBI PHY access; a bad merge undid bug fix in a previous commit.
Date: Wed, 28 Mar 2012 10:05:54 +0200
Message-ID: <1332921954-11695-1-git-send-email-kenth.eriksson@transmode.com>
Cc: Kenth Eriksson <kenth.eriksson@transmode.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:36616 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751513Ab2C1IOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 04:14:38 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id E97A4258283
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 10:06:33 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b26e478f undid bug fix in commit c3e072f8, with the result that non TBI (e.g. MDIO) PHYs cannot be accessed.

Signed-off-by: Kenth Eriksson <kenth.eriksson@transmode.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 9eb8159..f7f0bf5 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -356,13 +356,13 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 
 		if (prop)
 			tbiaddr = *prop;
-	}
 
-	if (tbiaddr == -1) {
-		err = -EBUSY;
-		goto err_free_irqs;
-	} else {
-		out_be32(tbipa, tbiaddr);
+		if (tbiaddr == -1) {
+			err = -EBUSY;
+			goto err_free_irqs;
+		} else {
+			out_be32(tbipa, tbiaddr);
+		}
 	}
 
 	err = of_mdiobus_register(new_bus, np);
-- 
1.7.3.4
