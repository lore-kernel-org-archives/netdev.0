From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] mlxsw: spectrum: Change ENOTSUPP to EOPNOTSUPP
Date: Mon,  9 Jan 2017 11:25:48 +0100
Message-ID: <1483957548-3531-6-git-send-email-jiri@resnulli.us>
References: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34964 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758630AbdAIKZ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 05:25:57 -0500
Received: by mail-wm0-f65.google.com with SMTP id l2so21007107wml.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 02:25:56 -0800 (PST)
In-Reply-To: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

As ENOTSUPP is specific to NFS, change the return error value to
EOPNOTSUPP in various places in the mlxsw driver.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1f4fdce..d0e803f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1193,7 +1193,7 @@ mlxsw_sp_port_add_cls_matchall_mirror(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	if (!mlxsw_sp_port_dev_check(to_dev)) {
 		netdev_err(mlxsw_sp_port->dev, "Cannot mirror to a non-spectrum port");
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 	to_port = netdev_priv(to_dev);
 
@@ -1229,7 +1229,7 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	if (!tc_single_action(cls->exts)) {
 		netdev_err(mlxsw_sp_port->dev, "only singular actions are supported\n");
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 
 	mall_tc_entry = kzalloc(sizeof(*mall_tc_entry), GFP_KERNEL);
@@ -1309,7 +1309,7 @@ static int mlxsw_sp_setup_tc(struct net_device *dev, u32 handle,
 		}
 	}
 
-	return -ENOTSUPP;
+	return -EOPNOTSUPP;
 }
 
 static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
@@ -1652,7 +1652,7 @@ mlxsw_sp_get_hw_stats_by_group(struct mlxsw_sp_port_hw_stats **p_hw_stats,
 		break;
 	default:
 		WARN_ON(1);
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 	return 0;
 }
-- 
2.7.4
