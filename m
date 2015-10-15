From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/15] mlxsw: Introduce mlxsw_reg_spms_vid_pack helper and use it
Date: Thu, 15 Oct 2015 17:43:26 +0200
Message-ID: <1444923809-20785-13-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33103 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbbJOPnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:46 -0400
Received: by lffv3 with SMTP id v3so33312025lff.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:45 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce separate helper for packing SPMS VIDs, as it can be used for
multiple VIDs and not only for one as previous SPMS pack function
provided.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 8 ++++++--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 3 ++-
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 6fca13a..7595cf1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -192,11 +192,15 @@ enum mlxsw_reg_spms_state {
  */
 MLXSW_ITEM_BIT_ARRAY(reg, spms, state, 0x04, 0x400, 2);
 
-static inline void mlxsw_reg_spms_pack(char *payload, u8 local_port, u16 vid,
-				       enum mlxsw_reg_spms_state state)
+static inline void mlxsw_reg_spms_pack(char *payload, u8 local_port)
 {
 	MLXSW_REG_ZERO(spms, payload);
 	mlxsw_reg_spms_local_port_set(payload, local_port);
+}
+
+static inline void mlxsw_reg_spms_vid_pack(char *payload, u16 vid,
+					   enum mlxsw_reg_spms_state state)
+{
 	mlxsw_reg_spms_state_set(payload, vid, state);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 39a0074..0c0205c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -923,7 +923,8 @@ static int mlxsw_sx_port_stp_state_set(struct mlxsw_sx_port *mlxsw_sx_port,
 	spms_pl = kmalloc(MLXSW_REG_SPMS_LEN, GFP_KERNEL);
 	if (!spms_pl)
 		return -ENOMEM;
-	mlxsw_reg_spms_pack(spms_pl, mlxsw_sx_port->local_port, vid, state);
+	mlxsw_reg_spms_pack(spms_pl, mlxsw_sx_port->local_port);
+	mlxsw_reg_spms_vid_pack(spms_pl, vid, state);
 	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(spms), spms_pl);
 	kfree(spms_pl);
 	return err;
-- 
1.9.3
