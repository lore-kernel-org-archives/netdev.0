From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/13] mlxsw: acl: Change trap ACL action to get the trap_id as a parameter
Date: Tue, 19 Sep 2017 10:00:11 +0200
Message-ID: <20170919080020.5870-5-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33748 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751588AbdISIA1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:27 -0400
Received: by mail-wr0-f196.google.com with SMTP id b9so1723962wra.0
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:26 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Allow the trap ACL action to be configured with different traps. This
allows the multicast router offloading code to use that same ACL action
with the multicast router traps. By using different traps, the multicast
router can have different trap policies and can handle the packet
differently.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c | 4 ++--
 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c          | 3 ++-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
index 65a32d7..ab3ffe7a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
@@ -712,7 +712,7 @@ int mlxsw_afa_block_append_drop(struct mlxsw_afa_block *block)
 }
 EXPORT_SYMBOL(mlxsw_afa_block_append_drop);
 
-int mlxsw_afa_block_append_trap(struct mlxsw_afa_block *block)
+int mlxsw_afa_block_append_trap(struct mlxsw_afa_block *block, u16 trap_id)
 {
 	char *act = mlxsw_afa_block_append_action(block,
 						  MLXSW_AFA_TRAPDISC_CODE,
@@ -722,7 +722,7 @@ int mlxsw_afa_block_append_trap(struct mlxsw_afa_block *block)
 		return -ENOBUFS;
 	mlxsw_afa_trapdisc_pack(act, MLXSW_AFA_TRAPDISC_TRAP_ACTION_TRAP,
 				MLXSW_AFA_TRAPDISC_FORWARD_ACTION_DISCARD,
-				MLXSW_TRAP_ID_ACL0);
+				trap_id);
 	return 0;
 }
 EXPORT_SYMBOL(mlxsw_afa_block_append_trap);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
index 5dbb31f..501819c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
@@ -60,7 +60,7 @@ u32 mlxsw_afa_block_first_set_kvdl_index(struct mlxsw_afa_block *block);
 void mlxsw_afa_block_continue(struct mlxsw_afa_block *block);
 void mlxsw_afa_block_jump(struct mlxsw_afa_block *block, u16 group_id);
 int mlxsw_afa_block_append_drop(struct mlxsw_afa_block *block);
-int mlxsw_afa_block_append_trap(struct mlxsw_afa_block *block);
+int mlxsw_afa_block_append_trap(struct mlxsw_afa_block *block, u16 trap_id);
 int mlxsw_afa_block_append_fwd(struct mlxsw_afa_block *block,
 			       u8 local_port, bool in_port);
 int mlxsw_afa_block_append_vlan_modify(struct mlxsw_afa_block *block,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index 2523785..eede75f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -396,7 +396,8 @@ int mlxsw_sp_acl_rulei_act_drop(struct mlxsw_sp_acl_rule_info *rulei)
 
 int mlxsw_sp_acl_rulei_act_trap(struct mlxsw_sp_acl_rule_info *rulei)
 {
-	return mlxsw_afa_block_append_trap(rulei->act_block);
+	return mlxsw_afa_block_append_trap(rulei->act_block,
+					   MLXSW_TRAP_ID_ACL0);
 }
 
 int mlxsw_sp_acl_rulei_act_fwd(struct mlxsw_sp *mlxsw_sp,
-- 
2.9.5
