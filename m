From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/13] mlxsw: spectrum_router: Export RIF dev access function
Date: Tue, 19 Sep 2017 10:00:19 +0200
Message-ID: <20170919080020.5870-13-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35699 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751626AbdISIAd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:33 -0400
Received: by mail-wr0-f195.google.com with SMTP id n64so1712935wrb.2
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:33 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The mlxsw_sp_rif struct, defined as private struct in spectrum_router.c
will be used in the multicast router source file. Due to the fact that the
dev field will be needed by the multicast router logic, add an access
function to it.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 5 +++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h | 1 +
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2cfb3f5..0bd93dc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5049,6 +5049,11 @@ int mlxsw_sp_rif_dev_ifindex(const struct mlxsw_sp_rif *rif)
 	return rif->dev->ifindex;
 }
 
+const struct net_device *mlxsw_sp_rif_dev(const struct mlxsw_sp_rif *rif)
+{
+	return rif->dev;
+}
+
 static struct mlxsw_sp_rif *
 mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 		    const struct mlxsw_sp_rif_params *params)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index 345fcc4..ae4c99b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -69,6 +69,7 @@ u16 mlxsw_sp_rif_index(const struct mlxsw_sp_rif *rif);
 u16 mlxsw_sp_ipip_lb_rif_index(const struct mlxsw_sp_rif_ipip_lb *rif);
 u16 mlxsw_sp_ipip_lb_ul_vr_id(const struct mlxsw_sp_rif_ipip_lb *rif);
 int mlxsw_sp_rif_dev_ifindex(const struct mlxsw_sp_rif *rif);
+const struct net_device *mlxsw_sp_rif_dev(const struct mlxsw_sp_rif *rif);
 int mlxsw_sp_rif_counter_value_get(struct mlxsw_sp *mlxsw_sp,
 				   struct mlxsw_sp_rif *rif,
 				   enum mlxsw_sp_rif_counter_dir dir,
-- 
2.9.5
