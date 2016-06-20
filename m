From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/23] mlxsw: spectrum: Remove unnecessary checks from event processing
Date: Mon, 20 Jun 2016 23:04:02 +0200
Message-ID: <1466456661-5260-5-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:33693 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577AbcFTVQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:16:19 -0400
Received: by mail-lb0-f193.google.com with SMTP id o4so241923lbp.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:16:05 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When upper device of a VLAN device changes we already made sure it's
a bridge device in PRECHANGEUPPER, so no need to check it's a master
device in CHANGEUPPER.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 46c867f..e55c685 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3440,10 +3440,10 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 	switch (event) {
 	case NETDEV_PRECHANGEUPPER:
 		upper_dev = info->upper_dev;
-		if (!info->master || !info->linking)
-			break;
 		if (!netif_is_bridge_master(upper_dev))
 			return -EINVAL;
+		if (!info->linking)
+			break;
 		/* We can't have multiple VLAN interfaces configured on
 		 * the same port and being members in the same bridge.
 		 */
@@ -3453,8 +3453,6 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 		break;
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
-		if (!info->master)
-			break;
 		if (info->linking) {
 			if (!mlxsw_sp_vport) {
 				WARN_ON(!mlxsw_sp_vport);
-- 
2.5.5
