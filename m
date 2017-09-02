From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 19/21] mlxsw: spectrum_router: Add loopback accessors
Date: Sat,  2 Sep 2017 17:21:24 +0200
Message-ID: <20170902152126.17286-20-jiri@resnulli.us>
References: <20170902152126.17286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36242 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752765AbdIBPV7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 11:21:59 -0400
Received: by mail-wm0-f67.google.com with SMTP id p17so2641445wmd.3
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 08:21:58 -0700 (PDT)
In-Reply-To: <20170902152126.17286-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

struct mlxsw_sp_rif is a router-private structure, and therefore
everything related to it is as well: parameters, and derived RIF types
including loopbacks. IPIP module needs access to some details of
loopback interfaces, but exporting all the RIF shebang would create too
large an interface.

So instead export just the bare minimum necessary: accessors for RIF
index and underlay VRF ID.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 10 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h |  3 +++
 2 files changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2189cf0..6068eea 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5007,6 +5007,16 @@ u16 mlxsw_sp_rif_index(const struct mlxsw_sp_rif *rif)
 	return rif->rif_index;
 }
 
+u16 mlxsw_sp_ipip_lb_rif_index(const struct mlxsw_sp_rif_ipip_lb *lb_rif)
+{
+	return lb_rif->common.rif_index;
+}
+
+u16 mlxsw_sp_ipip_lb_ul_vr_id(const struct mlxsw_sp_rif_ipip_lb *lb_rif)
+{
+	return lb_rif->ul_vr_id;
+}
+
 int mlxsw_sp_rif_dev_ifindex(const struct mlxsw_sp_rif *rif)
 {
 	return rif->dev->ifindex;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index 4276f5f..9632476 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -48,6 +48,7 @@ union mlxsw_sp_l3addr {
 	struct in6_addr addr6;
 };
 
+struct mlxsw_sp_rif_ipip_lb;
 struct mlxsw_sp_rif_ipip_lb_config {
 	enum mlxsw_reg_ritr_loopback_ipip_type lb_ipipt;
 	u32 okey;
@@ -65,6 +66,8 @@ struct mlxsw_sp_neigh_entry;
 struct mlxsw_sp_rif *mlxsw_sp_rif_by_index(const struct mlxsw_sp *mlxsw_sp,
 					   u16 rif_index);
 u16 mlxsw_sp_rif_index(const struct mlxsw_sp_rif *rif);
+u16 mlxsw_sp_ipip_lb_rif_index(const struct mlxsw_sp_rif_ipip_lb *rif);
+u16 mlxsw_sp_ipip_lb_ul_vr_id(const struct mlxsw_sp_rif_ipip_lb *rif);
 int mlxsw_sp_rif_dev_ifindex(const struct mlxsw_sp_rif *rif);
 int mlxsw_sp_rif_counter_value_get(struct mlxsw_sp *mlxsw_sp,
 				   struct mlxsw_sp_rif *rif,
-- 
2.9.3
