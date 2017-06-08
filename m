From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 13/19] net: Remove support for bridge bypass ndos from stacked devices
Date: Thu,  8 Jun 2017 08:44:22 +0200
Message-ID: <20170608064428.4785-14-jiri@resnulli.us>
References: <20170608064428.4785-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com,
        nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35449 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751637AbdFHGpA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:45:00 -0400
Received: by mail-wm0-f66.google.com with SMTP id g15so5661708wmc.2
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:44:59 -0700 (PDT)
In-Reply-To: <20170608064428.4785-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Remove support for bridge bypass ndos from stacked devices. At this point
no driver which supports stack device behavior offload supports operation
with SELF flag. The case for upper device is already taken care of in both
of the following cases:

1. FDB add/del - driver should check at the notification cb if the
                 stacked device contains his ports.

2. Port attribute - calls switchdev code directly which checks
                    for case of stack device.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/bonding/bond_main.c | 6 ------
 drivers/net/team/team.c         | 6 ------
 net/8021q/vlan_dev.c            | 6 ------
 3 files changed, 18 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d4484d1..7d94743 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4175,12 +4175,6 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_add_slave		= bond_enslave,
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
-	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
-	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
-	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
-	.ndo_fdb_add		= switchdev_port_fdb_add,
-	.ndo_fdb_del		= switchdev_port_fdb_del,
-	.ndo_fdb_dump		= switchdev_port_fdb_dump,
 	.ndo_features_check	= passthru_features_check,
 };
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 6c5d5ef..a3ec189 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2005,12 +2005,6 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_del_slave		= team_del_slave,
 	.ndo_fix_features	= team_fix_features,
 	.ndo_change_carrier     = team_change_carrier,
-	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
-	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
-	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
-	.ndo_fdb_add		= switchdev_port_fdb_add,
-	.ndo_fdb_del		= switchdev_port_fdb_del,
-	.ndo_fdb_dump		= switchdev_port_fdb_dump,
 	.ndo_features_check	= passthru_features_check,
 };
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 953b672..56d4b69 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -797,12 +797,6 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_netpoll_cleanup	= vlan_dev_netpoll_cleanup,
 #endif
 	.ndo_fix_features	= vlan_dev_fix_features,
-	.ndo_fdb_add		= switchdev_port_fdb_add,
-	.ndo_fdb_del		= switchdev_port_fdb_del,
-	.ndo_fdb_dump		= switchdev_port_fdb_dump,
-	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
-	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
-	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_get_lock_subclass  = vlan_dev_get_lock_subclass,
 	.ndo_get_iflink		= vlan_dev_get_iflink,
 };
-- 
2.9.3
