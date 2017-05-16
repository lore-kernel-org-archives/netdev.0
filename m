From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/12] mlxsw: spectrum_switchdev: Remove redundant check
Date: Tue, 16 May 2017 19:38:30 +0200
Message-ID: <20170516173835.2978-8-jiri@resnulli.us>
References: <20170516173835.2978-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36694 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752610AbdEPRit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:38:49 -0400
Received: by mail-wr0-f194.google.com with SMTP id v42so14918442wrc.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:38:48 -0700 (PDT)
In-Reply-To: <20170516173835.2978-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Since commit 97c242902c20 ("switchdev: Execute bridge ndos only for
bridge ports") switchdev code checks that port is bridged, so no need to
perform the same check in the driver.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 85790d3..d9393f7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -374,9 +374,6 @@ static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	unsigned long uc_flood = mlxsw_sp_port->uc_flood ? BR_FLOOD : 0;
 	int err;
 
-	if (!mlxsw_sp_port->bridged)
-		return -EINVAL;
-
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
@@ -796,9 +793,6 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	u16 vid, old_pvid;
 	int err;
 
-	if (!mlxsw_sp_port->bridged)
-		return -EINVAL;
-
 	err = mlxsw_sp_port_fid_join(mlxsw_sp_port, vid_begin, vid_end);
 	if (err) {
 		netdev_err(dev, "Failed to join FIDs\n");
@@ -1162,9 +1156,6 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 {
 	u16 vid, pvid;
 
-	if (!mlxsw_sp_port->bridged)
-		return -EINVAL;
-
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_port, vid_begin, vid_end,
 				       false);
 
-- 
2.9.3
