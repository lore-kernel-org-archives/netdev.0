From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum_dpipe: Fix entries dump of the adjacency table
Date: Tue, 24 Oct 2017 10:11:42 +0200
Message-ID: <20171024081142.996-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:49802 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751730AbdJXILo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 04:11:44 -0400
Received: by mail-wr0-f193.google.com with SMTP id g90so19758816wrd.6
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 01:11:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

During the dump the per netlink packet entry counter should be zeroed out
when new packet is created.

Fixes: 190d38a52a73 ("mlxsw: spectrum_dpipe: Add support for adjacency table dump")
Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reported-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 6ea6435..96fdba7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -1093,6 +1093,7 @@ mlxsw_sp_dpipe_table_adj_entries_get(struct mlxsw_sp *mlxsw_sp,
 		goto err_ctx_prepare;
 	j = 0;
 	nh_skip = nh_count;
+	nh_count = 0;
 	mlxsw_sp_nexthop_for_each(nh, mlxsw_sp->router) {
 		if (!mlxsw_sp_nexthop_offload(nh) ||
 		    mlxsw_sp_nexthop_group_has_ipip(nh))
-- 
2.9.5
