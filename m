From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: Set a "dsa" device_type
Date: Wed, 23 Sep 2015 18:19:58 -0700
Message-ID: <1443057598-25729-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34176 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932226AbbIXBUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 21:20:18 -0400
Received: by padhy16 with SMTP id hy16so56252088pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 18:20:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide a device_type information for slave network devices created by
DSA, this is useful for user-space application to easily locate/search
for devices of a specific kind.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index cce97385f743..40f9e369dc8e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -962,6 +962,10 @@ static const struct switchdev_ops dsa_slave_switchdev_ops = {
 	.switchdev_port_obj_dump	= dsa_slave_port_obj_dump,
 };
 
+static struct device_type dsa_type = {
+	.name	= "dsa",
+};
+
 static void dsa_slave_adjust_link(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -1150,6 +1154,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->priv_flags |= IFF_NO_QUEUE;
 	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
 	slave_dev->switchdev_ops = &dsa_slave_switchdev_ops;
+	SET_NETDEV_DEVTYPE(slave_dev, &dsa_type);
 
 	netdev_for_each_tx_queue(slave_dev, dsa_slave_set_lockdep_class_one,
 				 NULL);
-- 
2.1.0
