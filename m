From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: dsa: Implement ndo_get_phys_port_name()
Date: Tue, 10 Jan 2017 12:32:36 -0800
Message-ID: <20170110203237.23907-2-f.fainelli@gmail.com>
References: <20170110203237.23907-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@resnulli.us,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35184 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbdAJUcs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:32:48 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so11453436pfa.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 12:32:48 -0800 (PST)
In-Reply-To: <20170110203237.23907-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return the physical port number of a DSA created network device using
ndo_get_phys_port_name().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 5cd5b8137c08..fed3fbd403cb 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -990,6 +990,15 @@ static int dsa_slave_get_phys_port_id(struct net_device *dev,
 
 	ppid->id_len = sizeof(p->port);
 	memcpy(ppid->id, &p->port, ppid->id_len);
+}
+
+static int dsa_slave_get_phys_port_name(struct net_device *dev,
+					char *name, size_t len)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	if (snprintf(name, len, "p%d", p->port) >= len)
+		return -EINVAL;
 
 	return 0;
 }
@@ -1042,6 +1051,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_get_phys_port_id	= dsa_slave_get_phys_port_id,
+	.ndo_get_phys_port_name	= dsa_slave_get_phys_port_name,
 };
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
-- 
2.9.3
