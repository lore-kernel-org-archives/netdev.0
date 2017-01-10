From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] Revert "net: dsa: Implement ndo_get_phys_port_id"
Date: Tue, 10 Jan 2017 12:32:37 -0800
Message-ID: <20170110203237.23907-3-f.fainelli@gmail.com>
References: <20170110203237.23907-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@resnulli.us,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34124 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751065AbdAJUct (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:32:49 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so9285561pfb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 12:32:49 -0800 (PST)
In-Reply-To: <20170110203237.23907-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 3a543ef479868e36c95935de320608a7e41466ca ("net: dsa:
Implement ndo_get_phys_port_id") since it misuses the purpose of
ndo_get_phys_port_id(). We have ndo_get_phys_port_name() to do the
correct thing for us now.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index fed3fbd403cb..0cdcaf526987 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -983,15 +983,6 @@ static void dsa_slave_poll_controller(struct net_device *dev)
 }
 #endif
 
-static int dsa_slave_get_phys_port_id(struct net_device *dev,
-				      struct netdev_phys_item_id *ppid)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-
-	ppid->id_len = sizeof(p->port);
-	memcpy(ppid->id, &p->port, ppid->id_len);
-}
-
 static int dsa_slave_get_phys_port_name(struct net_device *dev,
 					char *name, size_t len)
 {
@@ -1050,7 +1041,6 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
-	.ndo_get_phys_port_id	= dsa_slave_get_phys_port_id,
 	.ndo_get_phys_port_name	= dsa_slave_get_phys_port_name,
 };
 
-- 
2.9.3
