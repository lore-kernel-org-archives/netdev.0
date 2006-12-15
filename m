From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/3] chelsio: fix error path
Date: Fri, 15 Dec 2006 11:07:17 -0800
Message-ID: <20061215190813.630932000@osdl.org>
References: <20061215190716.956791000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:36030 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226AbWLOTJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 14:09:32 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=chelsio-coverity.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix handling of allocation failure.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.20-rc1.orig/drivers/net/chelsio/my3126.c
+++ linux-2.6.20-rc1/drivers/net/chelsio/my3126.c
@@ -170,13 +170,14 @@ static struct cphy *my3126_phy_create(ad
 {
 	struct cphy *cphy = kzalloc(sizeof (*cphy), GFP_KERNEL);
 
-	if (cphy)
-		cphy_init(cphy, adapter, phy_addr, &my3126_ops, mdio_ops);
+	if (!cphy)
+		return NULL;
 
+	cphy_init(cphy, adapter, phy_addr, &my3126_ops, mdio_ops);
 	INIT_DELAYED_WORK(&cphy->phy_update, my3216_poll);
 	cphy->bmsr = 0;
 
-	return (cphy);
+	return cphy;
 }
 
 /* Chip Reset */

-- 

