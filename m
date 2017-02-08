From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/15] mlxsw: spectrum_router: Nullify nexthop's neigh pointer
Date: Wed,  8 Feb 2017 11:16:28 +0100
Message-ID: <1486549002-2056-2-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36085 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752664AbdBHKQq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:46 -0500
Received: by mail-wr0-f194.google.com with SMTP id k90so8257167wrc.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:45 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When we invalidate a nexthop we should also invalidate its neighbour
entry pointer as it might be destroyed later on. This makes the nexthop
de-init function symmetric with its init and also ensures nobody will
try to access the neighbour entry.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index b19f69f..31680de 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1398,12 +1398,13 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 
 	__mlxsw_sp_nexthop_neigh_update(nh, true);
 	list_del(&nh->neigh_list_node);
+	nh->neigh_entry = NULL;
 
 	/* If that is the last nexthop connected to that neigh, remove from
 	 * nexthop_neighs_list
 	 */
-	if (list_empty(&nh->neigh_entry->nexthop_list))
-		list_del(&nh->neigh_entry->nexthop_neighs_list_node);
+	if (list_empty(&neigh_entry->nexthop_list))
+		list_del(&neigh_entry->nexthop_neighs_list_node);
 
 	if (!neigh_entry->connected && list_empty(&neigh_entry->nexthop_list))
 		mlxsw_sp_neigh_entry_destroy(mlxsw_sp, neigh_entry);
-- 
2.7.4
