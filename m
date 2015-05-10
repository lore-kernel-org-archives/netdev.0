From: sfeldma@gmail.com
Subject: [PATCH net-next v7 20/24] switchdev: cut over to new switchdev_port_bridge_getlink
Date: Sun, 10 May 2015 09:48:05 -0700
Message-ID: <1431276489-64199-21-git-send-email-sfeldma@gmail.com>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36451 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbbEJQrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 12:47:22 -0400
Received: by pabsx10 with SMTP id sx10so90823002pab.3
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 09:47:22 -0700 (PDT)
In-Reply-To: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c      |    1 +
 drivers/net/ethernet/rocker/rocker.c |   15 +--------------
 drivers/net/team/team.c              |    1 +
 3 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index bb47661..b361d8c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4040,6 +4040,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
+	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 17a4c55..56ee316 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4295,19 +4295,6 @@ skip:
 	return idx;
 }
 
-static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-				      struct net_device *dev,
-				      u32 filter_mask, int nlflags)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	u16 mode = BRIDGE_MODE_UNDEF;
-	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
-
-	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
-				       rocker_port->brport_flags, mask,
-				       nlflags);
-}
-
 static int rocker_port_get_phys_port_name(struct net_device *dev,
 					  char *buf, size_t len)
 {
@@ -4334,8 +4321,8 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_add			= rocker_port_fdb_add,
 	.ndo_fdb_del			= rocker_port_fdb_del,
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
+	.ndo_bridge_getlink		= switchdev_port_bridge_getlink,
 	.ndo_bridge_setlink		= switchdev_port_bridge_setlink,
-	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
 	.ndo_bridge_dellink		= switchdev_port_bridge_dellink,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 };
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 0283753..bda32be 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1978,6 +1978,7 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_fix_features	= team_fix_features,
 	.ndo_change_carrier     = team_change_carrier,
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
+	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
-- 
1.7.10.4
