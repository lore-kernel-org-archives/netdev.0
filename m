From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/14] switchdev: vlan: Use switchdev_port* in vlan_netdev_ops
Date: Tue, 15 Dec 2015 16:03:34 +0100
Message-ID: <1450191827-6679-2-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36948 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933406AbbLOPDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:03:53 -0500
Received: by mail-wm0-f49.google.com with SMTP id n186so30036194wmn.0
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:03:52 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We need to be able to propagate static FDB entries and certain bridge
port attributes (e.g. learning, flooding) down to the port netdev
driver when bridge port is a VLAN interface.

Achieve that by setting ndo_bridge* and ndo_fdb* in vlan_netdev_ops to
the corresponding switchdev_port* functions. This is consistent with
team and bond devices.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/8021q/vlan_dev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index fded865..9f4bd13 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -30,6 +30,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <net/arp.h>
+#include <net/switchdev.h>
 
 #include "vlan.h"
 #include "vlanproc.h"
@@ -774,6 +775,12 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_netpoll_cleanup	= vlan_dev_netpoll_cleanup,
 #endif
 	.ndo_fix_features	= vlan_dev_fix_features,
+	.ndo_fdb_add		= switchdev_port_fdb_add,
+	.ndo_fdb_del		= switchdev_port_fdb_del,
+	.ndo_fdb_dump		= switchdev_port_fdb_dump,
+	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
+	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
+	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_get_lock_subclass  = vlan_dev_get_lock_subclass,
 	.ndo_get_iflink		= vlan_dev_get_iflink,
 };
-- 
1.9.3
