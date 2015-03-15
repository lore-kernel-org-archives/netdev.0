From: sfeldma@gmail.com
Subject: [PATCH net-next 4/5] dsa: move to new swdev ops
Date: Sat, 14 Mar 2015 23:15:06 -0700
Message-ID: <1426400107-6072-5-git-send-email-sfeldma@gmail.com>
References: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:36319 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbbCOGOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 02:14:19 -0400
Received: by pdbcz9 with SMTP id cz9so25864156pdb.3
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2015 23:14:19 -0700 (PDT)
In-Reply-To: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/dsa/slave.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6511552..2138d99 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -572,8 +572,11 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
-	.ndo_switch_parent_id_get = dsa_slave_parent_id_get,
-	.ndo_switch_port_stp_update = dsa_slave_stp_update,
+};
+
+static const struct swdev_ops dsa_slave_swdev_ops = {
+	.swdev_parent_id_get = dsa_slave_parent_id_get,
+	.swdev_port_stp_update = dsa_slave_stp_update,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
@@ -755,6 +758,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	eth_hw_addr_inherit(slave_dev, master);
 	slave_dev->tx_queue_len = 0;
 	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
+	slave_dev->swdev_ops = &dsa_slave_swdev_ops;
 
 	SET_NETDEV_DEV(slave_dev, parent);
 	slave_dev->dev.of_node = ds->pd->port_dn[port];
-- 
1.7.10.4
