From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] mlxsw: spectrum_dpipe: Fix host table dump
Date: Sat, 26 Aug 2017 08:35:39 +0200
Message-ID: <20170826063539.2741-3-jiri@resnulli.us>
References: <20170826063539.2741-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36199 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751868AbdHZGfq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 02:35:46 -0400
Received: by mail-wm0-f67.google.com with SMTP id j72so1723447wmi.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 23:35:45 -0700 (PDT)
In-Reply-To: <20170826063539.2741-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

During the neighbor traversal the neighbors from different families
should be ignored.

Fixes: c58035a74aba ("mlxsw: spectrum_dpipe: Add support for IPv4 host table dump")
Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 3c8599f..3ea1314 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -516,6 +516,9 @@ mlxsw_sp_dpipe_table_host_entries_get(struct mlxsw_sp *mlxsw_sp,
 
 		rif_neigh_count = 0;
 		mlxsw_sp_rif_neigh_for_each(neigh_entry, rif) {
+			if (mlxsw_sp_neigh_entry_type(neigh_entry) != type)
+				continue;
+
 			if (rif_neigh_count < rif_neigh_skip)
 				goto skip;
 
-- 
2.9.3
