From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: spectrum: Fix helper function and port variable names
Date: Mon,  6 Mar 2017 21:25:20 +0100
Message-ID: <1488831921-5152-2-git-send-email-jiri@resnulli.us>
References: <1488831921-5152-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36016 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753149AbdCFUdR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 15:33:17 -0500
Received: by mail-wr0-f195.google.com with SMTP id l37so23146000wrc.3
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 12:31:57 -0800 (PST)
In-Reply-To: <1488831921-5152-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Commit dd82364c3ab9 ("mlxsw: Flip to the new dev walk API") did some
small changes in mlxsw code, but it did not respect the naming
conventions. So fix this now.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 16484f2..ae18067 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3326,13 +3326,13 @@ bool mlxsw_sp_port_dev_check(const struct net_device *dev)
 	return dev->netdev_ops == &mlxsw_sp_port_netdev_ops;
 }
 
-static int mlxsw_lower_dev_walk(struct net_device *lower_dev, void *data)
+static int mlxsw_sp_lower_dev_walk(struct net_device *lower_dev, void *data)
 {
-	struct mlxsw_sp_port **port = data;
+	struct mlxsw_sp_port **p_mlxsw_sp_port = data;
 	int ret = 0;
 
 	if (mlxsw_sp_port_dev_check(lower_dev)) {
-		*port = netdev_priv(lower_dev);
+		*p_mlxsw_sp_port = netdev_priv(lower_dev);
 		ret = 1;
 	}
 
@@ -3341,15 +3341,15 @@ static int mlxsw_lower_dev_walk(struct net_device *lower_dev, void *data)
 
 static struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find(struct net_device *dev)
 {
-	struct mlxsw_sp_port *port;
+	struct mlxsw_sp_port *mlxsw_sp_port;
 
 	if (mlxsw_sp_port_dev_check(dev))
 		return netdev_priv(dev);
 
-	port = NULL;
-	netdev_walk_all_lower_dev(dev, mlxsw_lower_dev_walk, &port);
+	mlxsw_sp_port = NULL;
+	netdev_walk_all_lower_dev(dev, mlxsw_sp_lower_dev_walk, &mlxsw_sp_port);
 
-	return port;
+	return mlxsw_sp_port;
 }
 
 static struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev)
@@ -3362,15 +3362,16 @@ static struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev)
 
 static struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find_rcu(struct net_device *dev)
 {
-	struct mlxsw_sp_port *port;
+	struct mlxsw_sp_port *mlxsw_sp_port;
 
 	if (mlxsw_sp_port_dev_check(dev))
 		return netdev_priv(dev);
 
-	port = NULL;
-	netdev_walk_all_lower_dev_rcu(dev, mlxsw_lower_dev_walk, &port);
+	mlxsw_sp_port = NULL;
+	netdev_walk_all_lower_dev_rcu(dev, mlxsw_sp_lower_dev_walk,
+				      &mlxsw_sp_port);
 
-	return port;
+	return mlxsw_sp_port;
 }
 
 struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev)
-- 
2.7.4
