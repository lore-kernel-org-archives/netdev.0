From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/12] mlxsw: spectrum: move "bridged" bool to u8 flags
Date: Wed, 28 Oct 2015 10:16:56 +0100
Message-ID: <1446023825-7162-4-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36419 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964828AbbJ1JRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:17:21 -0400
Received: by wicfx6 with SMTP id fx6so190667437wic.1
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:17:20 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

It is a flag anyway, so move it to existing u8 flag and don't waste mem.
Fix the flags to be in single u8 on the way.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6e9906d..e30b2da 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1899,12 +1899,12 @@ static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
 				if (err)
 					netdev_err(dev, "Failed to join bridge\n");
 				mlxsw_sp_master_bridge_inc(mlxsw_sp, upper_dev);
-				mlxsw_sp_port->bridged = true;
+				mlxsw_sp_port->bridged = 1;
 			} else {
 				err = mlxsw_sp_port_bridge_leave(mlxsw_sp_port);
 				if (err)
 					netdev_err(dev, "Failed to leave bridge\n");
-				mlxsw_sp_port->bridged = false;
+				mlxsw_sp_port->bridged = 0;
 				mlxsw_sp_master_bridge_dec(mlxsw_sp, upper_dev);
 			}
 		}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index fc00749..b4d8393 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -84,10 +84,10 @@ struct mlxsw_sp_port {
 	struct mlxsw_sp *mlxsw_sp;
 	u8 local_port;
 	u8 stp_state;
-	u8 learning:1;
-	u8 learning_sync:1;
+	u8 learning:1,
+	   learning_sync:1,
+	   bridged:1;
 	u16 pvid;
-	bool bridged;
 	/* 802.1Q bridge VLANs */
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	/* VLAN interfaces */
-- 
1.9.3
