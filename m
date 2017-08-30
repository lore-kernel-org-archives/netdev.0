From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/8] mlxsw: spectrum_router: Add IPv6 neighbor access helper
Date: Wed, 30 Aug 2017 14:03:02 +0200
Message-ID: <20170830120306.6128-5-jiri@resnulli.us>
References: <20170830120306.6128-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38155 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdH3MDT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:03:19 -0400
Received: by mail-wr0-f194.google.com with SMTP id j3so4024228wrb.5
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:03:19 -0700 (PDT)
In-Reply-To: <20170830120306.6128-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add helper for accessing destination IP in case of IPv6 neighbor.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 9 +++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h | 2 ++
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 1f41bcd..db57c0c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -947,6 +947,15 @@ u32 mlxsw_sp_neigh4_entry_dip(struct mlxsw_sp_neigh_entry *neigh_entry)
 	return ntohl(*((__be32 *) n->primary_key));
 }
 
+struct in6_addr *
+mlxsw_sp_neigh6_entry_dip(struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	struct neighbour *n;
+
+	n = neigh_entry->key.n;
+	return (struct in6_addr *) &n->primary_key;
+}
+
 int mlxsw_sp_neigh_counter_get(struct mlxsw_sp *mlxsw_sp,
 			       struct mlxsw_sp_neigh_entry *neigh_entry,
 			       u64 *p_counter)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index 5b68616..87a04af 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -65,6 +65,8 @@ int mlxsw_sp_neigh_entry_type(struct mlxsw_sp_neigh_entry *neigh_entry);
 unsigned char *
 mlxsw_sp_neigh_entry_ha(struct mlxsw_sp_neigh_entry *neigh_entry);
 u32 mlxsw_sp_neigh4_entry_dip(struct mlxsw_sp_neigh_entry *neigh_entry);
+struct in6_addr *
+mlxsw_sp_neigh6_entry_dip(struct mlxsw_sp_neigh_entry *neigh_entry);
 
 #define mlxsw_sp_rif_neigh_for_each(neigh_entry, rif)				\
 	for (neigh_entry = mlxsw_sp_rif_neigh_next(rif, NULL); neigh_entry;	\
-- 
2.9.3
