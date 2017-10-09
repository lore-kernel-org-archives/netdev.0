From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/5] mlxsw: spectrum: router: Export the mlxsw_sp_router_port function
Date: Mon,  9 Oct 2017 11:15:33 +0200
Message-ID: <20171009091535.1315-4-jiri@resnulli.us>
References: <20171009091535.1315-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:52477 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbdJIJPk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 05:15:40 -0400
Received: by mail-wm0-f66.google.com with SMTP id k4so21469735wmc.1
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 02:15:39 -0700 (PDT)
In-Reply-To: <20171009091535.1315-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

In Spectrum hardware, the router port is a virtual port that is the gateway
to the routing mechanism. Hence, in order for a packet to be L3 forwarded,
it must first be L2 forwarded to the router port inside the hardware.

Further patches in this patchset are going to introduce support in bridge
device used as an mrouter port. In this case, the router port index will be
needed in order to update the MDB entries to include the router port. Thus,
export the mlxsw_sp_router_port function, which returns the index of the
Spectrum router port.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index e0f8ea4..a072903 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5957,7 +5957,7 @@ static int mlxsw_sp_rif_vlan_fid_op(struct mlxsw_sp_rif *rif,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
 }
 
-static u8 mlxsw_sp_router_port(const struct mlxsw_sp *mlxsw_sp)
+u8 mlxsw_sp_router_port(const struct mlxsw_sp *mlxsw_sp)
 {
 	return mlxsw_core_max_ports(mlxsw_sp->core) + 1;
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index 3d44918..3f2d840 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -70,6 +70,7 @@ u16 mlxsw_sp_rif_index(const struct mlxsw_sp_rif *rif);
 u16 mlxsw_sp_ipip_lb_rif_index(const struct mlxsw_sp_rif_ipip_lb *rif);
 u16 mlxsw_sp_ipip_lb_ul_vr_id(const struct mlxsw_sp_rif_ipip_lb *rif);
 int mlxsw_sp_rif_dev_ifindex(const struct mlxsw_sp_rif *rif);
+u8 mlxsw_sp_router_port(const struct mlxsw_sp *mlxsw_sp);
 const struct net_device *mlxsw_sp_rif_dev(const struct mlxsw_sp_rif *rif);
 int mlxsw_sp_rif_counter_value_get(struct mlxsw_sp *mlxsw_sp,
 				   struct mlxsw_sp_rif *rif,
-- 
2.9.5
