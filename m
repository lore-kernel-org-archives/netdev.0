From: akpm@osdl.org
Subject: [patch 28/41] net: Add netconsole support to dm9000 driver
Date: Mon, 14 Aug 2006 23:00:15 -0700
Message-ID: <200608150600.k7F60Fkc012684@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, haokexin@gmail.com,
	ben-linux@fluff.org, s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37010 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965139AbWHOGAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:30 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kevin Hao" <haokexin@gmail.com>

Add netconsole support to dm9000 driver.

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Sascha Hauer <s.hauer@pengutronix.de>
Cc: Ben Dooks <ben-linux@fluff.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/dm9000.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff -puN drivers/net/dm9000.c~net-add-netconsole-support-to-dm9000-driver drivers/net/dm9000.c
--- a/drivers/net/dm9000.c~net-add-netconsole-support-to-dm9000-driver
+++ a/drivers/net/dm9000.c
@@ -339,6 +339,17 @@ static void dm9000_timeout(struct net_de
 	spin_unlock_irqrestore(&db->lock,flags);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ *Used by netconsole
+ */
+static void dm9000_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	dm9000_interrupt(dev->irq,dev,NULL);
+	enable_irq(dev->irq);
+}
+#endif
 
 /* dm9000_release_board
  *
@@ -538,6 +549,9 @@ dm9000_probe(struct platform_device *pde
 	ndev->stop		 = &dm9000_stop;
 	ndev->get_stats		 = &dm9000_get_stats;
 	ndev->set_multicast_list = &dm9000_hash_table;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	ndev->poll_controller	 = &dm9000_poll_controller;
+#endif
 
 #ifdef DM9000_PROGRAM_EEPROM
 	program_eeprom(db);
_
