From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 18/23] mlxsw: spectrum: Check if port is vPort using its VID
Date: Mon, 20 Jun 2016 23:04:16 +0200
Message-ID: <1466456661-5260-19-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35687 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbcFTVQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:16:38 -0400
Received: by mail-lf0-f65.google.com with SMTP id w130so6833643lfd.2
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:16:37 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When L3 interfaces will be introduced a vPort won't necessarily have a
FID assigned to it. This can happen if it's not member in a bridge (in
which case it's assigned a vFID) or doesn't have an IP address (in which
case it's assigned an rFID).

Therefore, instead check the VID parameter to test whether a port is a
vPort or not.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index d6cf6de..1d34419 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -259,12 +259,6 @@ mlxsw_sp_port_lagged_get(struct mlxsw_sp *mlxsw_sp, u16 lag_id, u8 port_index)
 	return mlxsw_sp_port && mlxsw_sp_port->lagged ? mlxsw_sp_port : NULL;
 }
 
-static inline bool
-mlxsw_sp_port_is_vport(const struct mlxsw_sp_port *mlxsw_sp_port)
-{
-	return mlxsw_sp_port->vport.f;
-}
-
 static inline struct net_device *
 mlxsw_sp_vport_br_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 {
@@ -277,6 +271,14 @@ mlxsw_sp_vport_vid_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 	return mlxsw_sp_vport->vport.vid;
 }
 
+static inline bool
+mlxsw_sp_port_is_vport(const struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
+
+	return vid != 0;
+}
+
 static inline u16
 mlxsw_sp_vport_fid_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 {
-- 
2.5.5
