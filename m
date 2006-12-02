From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 02/10] chelsio: use kzalloc
Date: Fri, 01 Dec 2006 16:36:14 -0800
Message-ID: <20061202003707.268826000@osdl.org>
References: <20061202003612.573260000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:43490 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162418AbWLBAjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 19:39:35 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=chelsio-kzalloc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kzalloc in several places.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


---
 drivers/net/chelsio/mv88x201x.c |    4 ++--
 drivers/net/chelsio/pm3393.c    |    3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

--- chelsio.orig/drivers/net/chelsio/mv88x201x.c
+++ chelsio/drivers/net/chelsio/mv88x201x.c
@@ -205,11 +205,11 @@ static struct cphy *mv88x201x_phy_create
 					 struct mdio_ops *mdio_ops)
 {
 	u32 val;
-	struct cphy *cphy = kmalloc(sizeof(*cphy), GFP_KERNEL);
+	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
 
 	if (!cphy)
 		return NULL;
-	memset(cphy, 0, sizeof(*cphy));
+
 	cphy_init(cphy, adapter, phy_addr, &mv88x201x_ops, mdio_ops);
 
 	/* Commands the PHY to enable XFP's clock. */
--- chelsio.orig/drivers/net/chelsio/pm3393.c
+++ chelsio/drivers/net/chelsio/pm3393.c
@@ -631,10 +631,9 @@ static struct cmac *pm3393_mac_create(ad
 {
 	struct cmac *cmac;
 
-	cmac = kmalloc(sizeof(*cmac) + sizeof(cmac_instance), GFP_KERNEL);
+	cmac = kzalloc(sizeof(*cmac) + sizeof(cmac_instance), GFP_KERNEL);
 	if (!cmac)
 		return NULL;
-	memset(cmac, 0, sizeof(*cmac));
 
 	cmac->ops = &pm3393_ops;
 	cmac->instance = (cmac_instance *) (cmac + 1);

-- 

