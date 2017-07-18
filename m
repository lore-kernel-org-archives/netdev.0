From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/22] mlxsw: spectrum_router: Enable IPv6 router
Date: Tue, 18 Jul 2017 10:10:09 +0200
Message-ID: <20170718081030.2781-2-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35471 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751436AbdGRIKf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:35 -0400
Received: by mail-wr0-f196.google.com with SMTP id a10so2869761wrd.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:34 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Before we add IPv6 constructs like traps and router interfaces, we first
need to enable IPv6 routing in the device.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h             | 4 +++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 4 ++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 0ca1968..ce6c63d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3953,10 +3953,12 @@ MLXSW_ITEM32(reg, rgcr, pcp_rw, 0x18, 16, 2);
  */
 MLXSW_ITEM32(reg, rgcr, activity_dis, 0x20, 0, 8);
 
-static inline void mlxsw_reg_rgcr_pack(char *payload, bool ipv4_en)
+static inline void mlxsw_reg_rgcr_pack(char *payload, bool ipv4_en,
+				       bool ipv6_en)
 {
 	MLXSW_REG_ZERO(rgcr, payload);
 	mlxsw_reg_rgcr_ipv4_en_set(payload, ipv4_en);
+	mlxsw_reg_rgcr_ipv6_en_set(payload, ipv6_en);
 }
 
 /* RITR - Router Interface Table Register
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 383fef5a..060134d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3697,7 +3697,7 @@ static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 		return -EIO;
 	max_rifs = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS);
 
-	mlxsw_reg_rgcr_pack(rgcr_pl, true);
+	mlxsw_reg_rgcr_pack(rgcr_pl, true, true);
 	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, max_rifs);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
 	if (err)
@@ -3709,7 +3709,7 @@ static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
 
-	mlxsw_reg_rgcr_pack(rgcr_pl, false);
+	mlxsw_reg_rgcr_pack(rgcr_pl, false, false);
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
 }
 
-- 
2.9.3
