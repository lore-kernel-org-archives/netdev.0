From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 3/4] mlxsw: spectrum_switchdev: Remove unused variable
Date: Wed, 12 Jul 2017 09:12:54 +0200
Message-ID: <20170712071255.1232-4-jiri@resnulli.us>
References: <20170712071255.1232-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33850 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdGLHNI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 03:13:08 -0400
Received: by mail-wr0-f193.google.com with SMTP id k67so3637125wrc.1
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 00:13:02 -0700 (PDT)
In-Reply-To: <20170712071255.1232-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Commit 10e23eb299fa ("mlxsw: spectrum: Remove support for bypass bridge
port attributes/vlan set") removed statements that used 'bridge_vlan',
but didn't remove the variable itself resulting in the following warning
with W=1:

warning: variable ‘bridge_vlan’ set but not used
[-Wunused-but-set-variable]

Remove the variable and suppress the warning.

Fixes: 10e23eb299fa ("mlxsw: spectrum: Remove support for bypass bridge port attributes/vlan set")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index cd89a3e..4733fe9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -979,7 +979,6 @@ mlxsw_sp_bridge_port_vlan_add(struct mlxsw_sp_port *mlxsw_sp_port,
 {
 	u16 pvid = mlxsw_sp_port_pvid_determine(mlxsw_sp_port, vid, is_pvid);
 	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
-	struct mlxsw_sp_bridge_vlan *bridge_vlan;
 	u16 old_pvid = mlxsw_sp_port->pvid;
 	int err;
 
@@ -1000,8 +999,6 @@ mlxsw_sp_bridge_port_vlan_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (err)
 		goto err_port_vlan_bridge_join;
 
-	bridge_vlan = mlxsw_sp_bridge_vlan_find(bridge_port, vid);
-
 	return 0;
 
 err_port_vlan_bridge_join:
-- 
2.9.3
