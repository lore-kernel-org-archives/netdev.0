From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/21] mlxsw: reg: Give mlxsw_reg_ratr_pack a type parameter
Date: Sat,  2 Sep 2017 17:21:11 +0200
Message-ID: <20170902152126.17286-7-jiri@resnulli.us>
References: <20170902152126.17286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:37351 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752660AbdIBPVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 11:21:39 -0400
Received: by mail-wr0-f195.google.com with SMTP id y15so852255wrc.4
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 08:21:39 -0700 (PDT)
In-Reply-To: <20170902152126.17286-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

To support IPIP, the driver needs to be able to construct an IPIP
adjacency. Change mlxsw_reg_ratr_pack to take an adjacency type as an
argument. Adjust the one existing caller.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h             | 2 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 27a378d..680bc7e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4482,11 +4482,13 @@ MLXSW_ITEM32(reg, ratr, ipip_ipv6_ptr, 0x1C, 0, 24);
 static inline void
 mlxsw_reg_ratr_pack(char *payload,
 		    enum mlxsw_reg_ratr_op op, bool valid,
+		    enum mlxsw_reg_ratr_type type,
 		    u32 adjacency_index, u16 egress_rif)
 {
 	MLXSW_REG_ZERO(ratr, payload);
 	mlxsw_reg_ratr_op_set(payload, op);
 	mlxsw_reg_ratr_v_set(payload, valid);
+	mlxsw_reg_ratr_type_set(payload, type);
 	mlxsw_reg_ratr_adjacency_index_low_set(payload, adjacency_index);
 	mlxsw_reg_ratr_adjacency_index_high_set(payload, adjacency_index >> 16);
 	mlxsw_reg_ratr_egress_router_interface_set(payload, egress_rif);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 3ddfbe3..4e47d45 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1928,7 +1928,8 @@ static int mlxsw_sp_nexthop_mac_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
 	char ratr_pl[MLXSW_REG_RATR_LEN];
 
 	mlxsw_reg_ratr_pack(ratr_pl, MLXSW_REG_RATR_OP_WRITE_WRITE_ENTRY,
-			    true, adj_index, neigh_entry->rif);
+			    true, MLXSW_REG_RATR_TYPE_ETHERNET,
+			    adj_index, neigh_entry->rif);
 	mlxsw_reg_ratr_eth_entry_pack(ratr_pl, neigh_entry->ha);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ratr), ratr_pl);
 }
-- 
2.9.3
