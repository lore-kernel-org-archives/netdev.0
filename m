From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] mlxsw: spectrum: Tidy up header file
Date: Sun,  4 Jun 2017 16:53:38 +0200
Message-ID: <20170604145340.14447-2-jiri@resnulli.us>
References: <20170604145340.14447-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34105 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751200AbdFDOxo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 10:53:44 -0400
Received: by mail-wr0-f196.google.com with SMTP id u101so2833725wrc.1
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2017 07:53:44 -0700 (PDT)
In-Reply-To: <20170604145340.14447-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Make it clear where functions are defined and move misplaced declaration
to their correct place.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Petr Machata <petrm@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 47 ++++++++++++++------------
 1 file changed, 25 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 1a83410..99760fd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -233,12 +233,6 @@ struct mlxsw_sp_port {
 	struct list_head vlans_list;
 };
 
-bool mlxsw_sp_port_dev_check(const struct net_device *dev);
-struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev);
-struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find(struct net_device *dev);
-struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev);
-void mlxsw_sp_port_dev_put(struct mlxsw_sp_port *mlxsw_sp_port);
-
 static inline bool
 mlxsw_sp_port_is_pause_en(const struct mlxsw_sp_port *mlxsw_sp_port)
 {
@@ -278,6 +272,7 @@ enum mlxsw_sp_flood_type {
 	MLXSW_SP_FLOOD_TYPE_MC,
 };
 
+/* spectrum_buffers.c */
 int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_buffers_fini(struct mlxsw_sp *mlxsw_sp);
 int mlxsw_sp_port_buffers_init(struct mlxsw_sp_port *mlxsw_sp_port);
@@ -315,12 +310,11 @@ int mlxsw_sp_sb_occ_tc_port_bind_get(struct mlxsw_core_port *mlxsw_core_port,
 u32 mlxsw_sp_cells_bytes(const struct mlxsw_sp *mlxsw_sp, u32 cells);
 u32 mlxsw_sp_bytes_cells(const struct mlxsw_sp *mlxsw_sp, u32 bytes);
 
+/* spectrum_switchdev.c */
 int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_switchdev_fini(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_port_switchdev_init(struct mlxsw_sp_port *mlxsw_sp_port);
 void mlxsw_sp_port_switchdev_fini(struct mlxsw_sp_port *mlxsw_sp_port);
-int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
-			   u16 vid_end, bool is_member, bool untagged);
 int mlxsw_sp_rif_fdb_op(struct mlxsw_sp *mlxsw_sp, const char *mac, u16 fid,
 			bool adding);
 void
@@ -332,6 +326,7 @@ void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 				struct net_device *brport_dev,
 				struct net_device *br_dev);
 
+/* spectrum.c */
 int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
 			  enum mlxsw_reg_qeec_hr hr, u8 index, u8 next_index,
 			  bool dwrr, u8 dwrr_weight);
@@ -352,24 +347,35 @@ int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
 struct mlxsw_sp_port_vlan *
 mlxsw_sp_port_vlan_get(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
 void mlxsw_sp_port_vlan_put(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan);
+int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
+			   u16 vid_end, bool is_member, bool untagged);
+int mlxsw_sp_flow_counter_get(struct mlxsw_sp *mlxsw_sp,
+			      unsigned int counter_index, u64 *packets,
+			      u64 *bytes);
+int mlxsw_sp_flow_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+				unsigned int *p_counter_index);
+void mlxsw_sp_flow_counter_free(struct mlxsw_sp *mlxsw_sp,
+				unsigned int counter_index);
+bool mlxsw_sp_port_dev_check(const struct net_device *dev);
+struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev);
+struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find(struct net_device *dev);
+struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev);
+void mlxsw_sp_port_dev_put(struct mlxsw_sp_port *mlxsw_sp_port);
 
+/* spectrum_dcb.c */
 #ifdef CONFIG_MLXSW_SPECTRUM_DCB
-
 int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port);
 void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port);
-
 #else
-
 static inline int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	return 0;
 }
-
 static inline void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 {}
-
 #endif
 
+/* spectrum_router.c */
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp);
 int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
@@ -383,12 +389,11 @@ void
 mlxsw_sp_port_vlan_router_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan);
 void mlxsw_sp_rif_destroy(struct mlxsw_sp_rif *rif);
 
+/* spectrum_kvdl.c */
 int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count,
 			u32 *p_entry_index);
 void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index);
 
-struct mlxsw_afk *mlxsw_sp_acl_afk(struct mlxsw_sp_acl *acl);
-
 struct mlxsw_sp_acl_rule_info {
 	unsigned int priority;
 	struct mlxsw_afk_element_values values;
@@ -429,6 +434,8 @@ struct mlxsw_sp_acl_ops {
 
 struct mlxsw_sp_acl_ruleset;
 
+/* spectrum_acl.c */
+struct mlxsw_afk *mlxsw_sp_acl_afk(struct mlxsw_sp_acl *acl);
 struct mlxsw_sp_acl_ruleset *
 mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp,
 			 struct net_device *dev, bool ingress,
@@ -492,22 +499,18 @@ struct mlxsw_sp_fid *mlxsw_sp_acl_dummy_fid(struct mlxsw_sp *mlxsw_sp);
 int mlxsw_sp_acl_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_acl_fini(struct mlxsw_sp *mlxsw_sp);
 
+/* spectrum_acl_tcam.c */
 extern const struct mlxsw_sp_acl_ops mlxsw_sp_acl_tcam_ops;
 
+/* spectrum_flower.c */
 int mlxsw_sp_flower_replace(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 			    __be16 protocol, struct tc_cls_flower_offload *f);
 void mlxsw_sp_flower_destroy(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 			     struct tc_cls_flower_offload *f);
 int mlxsw_sp_flower_stats(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 			  struct tc_cls_flower_offload *f);
-int mlxsw_sp_flow_counter_get(struct mlxsw_sp *mlxsw_sp,
-			      unsigned int counter_index, u64 *packets,
-			      u64 *bytes);
-int mlxsw_sp_flow_counter_alloc(struct mlxsw_sp *mlxsw_sp,
-				unsigned int *p_counter_index);
-void mlxsw_sp_flow_counter_free(struct mlxsw_sp *mlxsw_sp,
-				unsigned int counter_index);
 
+/* spectrum_fid.c */
 int mlxsw_sp_fid_flood_set(struct mlxsw_sp_fid *fid,
 			   enum mlxsw_sp_flood_type packet_type, u8 local_port,
 			   bool member);
-- 
2.9.3
