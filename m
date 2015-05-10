From: sfeldma@gmail.com
Subject: [PATCH net-next v7 16/24] switchdev: cut over to new switchdev_port_bridge_dellink
Date: Sun, 10 May 2015 09:48:01 -0700
Message-ID: <1431276489-64199-17-git-send-email-sfeldma@gmail.com>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34962 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbbEJQrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 12:47:17 -0400
Received: by pabtp1 with SMTP id tp1so90833553pab.2
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 09:47:17 -0700 (PDT)
In-Reply-To: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Rocker, bonding and team and switch over to the new
switchdev_port_bridge_dellink to avoid duplicating code in each driver.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/bonding/bond_main.c      |    2 +-
 drivers/net/ethernet/rocker/rocker.c |    1 +
 drivers/net/team/team.c              |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e1d8a03..bb47661 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4040,7 +4040,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
-	.ndo_bridge_dellink	= ndo_dflt_switchdev_port_bridge_dellink,
+	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
 
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index e94089e..17a4c55 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4336,6 +4336,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
 	.ndo_bridge_setlink		= switchdev_port_bridge_setlink,
 	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
+	.ndo_bridge_dellink		= switchdev_port_bridge_dellink,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 };
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index e6c4df2..0283753 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1978,7 +1978,7 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_fix_features	= team_fix_features,
 	.ndo_change_carrier     = team_change_carrier,
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
-	.ndo_bridge_dellink     = ndo_dflt_switchdev_port_bridge_dellink,
+	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
 
-- 
1.7.10.4
