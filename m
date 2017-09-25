From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/10] mlxsw: Add fields for mlxsw's meta header for adjacency table
Date: Mon, 25 Sep 2017 10:32:22 +0200
Message-ID: <20170925083230.1193-3-jiri@resnulli.us>
References: <20170925083230.1193-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33040 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933294AbdIYIcd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:32:33 -0400
Received: by mail-wr0-f193.google.com with SMTP id b9so1443838wra.0
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:32:33 -0700 (PDT)
In-Reply-To: <20170925083230.1193-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

This patch adds field for mlxsw's meta header which will be used to
describe the match/action behavior of the adjacency table.

The fields are:
1. Adj_index - The global index of the nexthop group in the adjacency
   table.

2. Adj_hash_index - Local index offset which is based on packets hash
   mod the nexthop group size.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 9164809..9253273 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -43,6 +43,8 @@ enum mlxsw_sp_field_metadata_id {
 	MLXSW_SP_DPIPE_FIELD_METADATA_ERIF_PORT,
 	MLXSW_SP_DPIPE_FIELD_METADATA_L3_FORWARD,
 	MLXSW_SP_DPIPE_FIELD_METADATA_L3_DROP,
+	MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_INDEX,
+	MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_HASH_INDEX,
 };
 
 static struct devlink_dpipe_field mlxsw_sp_dpipe_fields_metadata[] = {
@@ -62,6 +64,16 @@ static struct devlink_dpipe_field mlxsw_sp_dpipe_fields_metadata[] = {
 		.id = MLXSW_SP_DPIPE_FIELD_METADATA_L3_DROP,
 		.bitwidth = 1,
 	},
+	{
+		.name = "adj_index",
+		.id = MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_INDEX,
+		.bitwidth = 32,
+	},
+	{
+		.name = "adj_hash_index",
+		.id = MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_HASH_INDEX,
+		.bitwidth = 32,
+	},
 };
 
 enum mlxsw_sp_dpipe_header_id {
-- 
2.9.5
