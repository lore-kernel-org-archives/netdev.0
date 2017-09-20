From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/16] mlxsw: spectrum_switchdev: Remove mrouter flood in mdb flush
Date: Wed, 20 Sep 2017 16:15:15 +0200
Message-ID: <20170920141516.1402-16-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:37316 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbdITOPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:32 -0400
Received: by mail-wr0-f194.google.com with SMTP id u48so1582845wrf.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:31 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

In mdb flush the port is being removed from all the mids it is registered
to. But if the port is mrouter, all the mids floods to it.
This patch remove mrouter ports from mids it is not registered to in the
mdb flush.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index bf1a175..459cedc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1673,6 +1673,9 @@ mlxsw_sp_bridge_port_mdb_flush(struct mlxsw_sp_port *mlxsw_sp_port,
 		if (test_bit(mlxsw_sp_port->local_port, mid->ports_in_mid)) {
 			__mlxsw_sp_port_mdb_del(mlxsw_sp_port, bridge_port,
 						mid);
+		} else if (bridge_device->multicast_enabled &&
+			   bridge_port->mrouter) {
+			mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, false);
 		}
 	}
 }
-- 
2.9.5
