From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/8] mlxsw: spectrum_router: Add rif helper functions
Date: Sat, 25 Mar 2017 08:35:41 +0100
Message-ID: <1490427342-2061-8-git-send-email-jiri@resnulli.us>
References: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36311 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751107AbdCYHf4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 03:35:56 -0400
Received: by mail-wm0-f67.google.com with SMTP id x124so1838840wmf.3
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 00:35:55 -0700 (PDT)
In-Reply-To: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add rif helper function to access the rif index and rif devices ifindex.
This functions will be used by dpipe in order to dump the rif table.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 10 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h |  2 ++
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 5df234d..7caf04b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2928,6 +2928,16 @@ mlxsw_sp_rif_alloc(u16 rif_index, u16 vr_id, struct net_device *l3_dev,
 	return rif;
 }
 
+u16 mlxsw_sp_rif_index_get(struct mlxsw_sp_rif *rif)
+{
+	return rif->rif_index;
+}
+
+int mlxsw_sp_rif_dev_ifindex_get(struct mlxsw_sp_rif *rif)
+{
+	return rif->dev->ifindex;
+}
+
 static struct mlxsw_sp_rif *
 mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 			     struct net_device *l3_dev)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index f469dc9..dd0d183 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -42,6 +42,8 @@ enum mlxsw_sp_rif_counter_dir {
 	MLXSW_SP_RIF_COUNTER_EGRESS,
 };
 
+u16 mlxsw_sp_rif_index_get(struct mlxsw_sp_rif *rif);
+int mlxsw_sp_rif_dev_ifindex_get(struct mlxsw_sp_rif *rif);
 int mlxsw_sp_rif_counter_value_get(struct mlxsw_sp *mlxsw_sp,
 				   struct mlxsw_sp_rif *rif,
 				   enum mlxsw_sp_rif_counter_dir dir,
-- 
2.7.4
