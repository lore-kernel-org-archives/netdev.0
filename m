From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/3] chelsio: error path fix
Date: Mon, 8 Jan 2007 11:24:26 -0800
Message-ID: <20070108112426.2a5e43fa@dxpl.pdx.osdl.net>
References: <20061215190716.956791000@osdl.org>
	<4591912E.60402@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37320 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161232AbXAHT1C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 14:27:02 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4591912E.60402@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix handling of allocation failure.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- netdev-2.6.orig/drivers/net/chelsio/my3126.c
+++ netdev-2.6/drivers/net/chelsio/my3126.c
@@ -170,9 +170,10 @@ static struct cphy *my3126_phy_create(ad
 {
 	struct cphy *cphy = kzalloc(sizeof (*cphy), GFP_KERNEL);
 
-	if (cphy)
-		cphy_init(cphy, adapter, phy_addr, &my3126_ops, mdio_ops);
+	if (!cphy)
+		return NULL;
 
+	cphy_init(cphy, adapter, phy_addr, &my3126_ops, mdio_ops);
 	INIT_DELAYED_WORK(&cphy->phy_update, my3216_poll);
 	cphy->bmsr = 0;
 
