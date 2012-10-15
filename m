From: Rodolfo Giometti <giometti@linux.it>
Subject: [PATCH] net dsa: add phy's interrupts management
Date: Mon, 15 Oct 2012 15:33:28 +0200
Message-ID: <1350308008-17189-4-git-send-email-giometti@linux.it>
References: <1350308008-17189-1-git-send-email-giometti@linux.it>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Rodolfo Giometti <giometti@linux.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-196-116.sn1.eutelia.it ([62.94.196.116]:13953 "EHLO
	goldrake.enneenne.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753561Ab2JONyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 09:54:45 -0400
In-Reply-To: <1350308008-17189-1-git-send-email-giometti@linux.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rodolfo Giometti <giometti@linux.it>
---
 net/dsa/slave.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6e9e4546..817bbbd 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -340,6 +340,11 @@ static const struct net_device_ops trailer_netdev_ops = {
 };
 #endif
 
+static void dsa_slave_handle_link_change(struct net_device *dev)
+{
+	/* nop */
+}
+
 /* slave device setup *******************************************************/
 struct net_device *
 dsa_slave_create(struct dsa_switch *ds, struct device *parent,
@@ -400,8 +405,8 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	netif_carrier_off(slave_dev);
 
 	if (p->phy != NULL) {
-		phy_attach(slave_dev, dev_name(&p->phy->dev),
-			   0, PHY_INTERFACE_MODE_GMII);
+		phy_connect_direct(p->dev, p->phy, dsa_slave_handle_link_change,
+				0, PHY_INTERFACE_MODE_GMII);
 
 		p->phy->autoneg = AUTONEG_ENABLE;
 		p->phy->speed = 0;
-- 
1.7.9.5
