From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/6] mlxsw: spectrum: router: Export the mlxsw_sp_router_port function
Date: Thu,  5 Oct 2017 12:36:40 +0200
Message-ID: <20171005103642.1414-5-jiri@resnulli.us>
References: <20171005103642.1414-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33900 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751756AbdJEKgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:36:52 -0400
Received: by mail-wr0-f193.google.com with SMTP id z1so9404240wre.1
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 03:36:52 -0700 (PDT)
In-Reply-To: <20171005103642.1414-1-jiri@resnulli.us>
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
index 58bc04c..58adb23 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5947,7 +5947,7 @@ static int mlxsw_sp_rif_vlan_fid_op(struct mlxsw_sp_rif *rif,
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
