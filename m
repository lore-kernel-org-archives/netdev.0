From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum_dpipe: Fix sparse warnings
Date: Thu, 18 May 2017 09:22:45 +0200
Message-ID: <20170518072245.12494-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36544 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751155AbdERHWr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 03:22:47 -0400
Received: by mail-wm0-f66.google.com with SMTP id k15so7610925wmh.3
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 00:22:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

drivers/net/ethernet/mellanox/mlxsw//spectrum_dpipe.c:221:52: warning:
Using plain integer as NULL pointer
drivers/net/ethernet/mellanox/mlxsw//spectrum_dpipe.c:221:74: warning:
Using plain integer as NULL pointer

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index ce2534d..096212d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -217,7 +217,7 @@ static int
 mlxsw_sp_table_erif_entries_dump(void *priv, bool counters_enabled,
 				 struct devlink_dpipe_dump_ctx *dump_ctx)
 {
-	struct devlink_dpipe_value match_value = {{0}}, action_value = {{0}};
+	struct devlink_dpipe_value match_value, action_value;
 	struct devlink_dpipe_action action = {0};
 	struct devlink_dpipe_match match = {0};
 	struct devlink_dpipe_entry entry = {0};
@@ -226,6 +226,9 @@ mlxsw_sp_table_erif_entries_dump(void *priv, bool counters_enabled,
 	int i, j;
 	int err;
 
+	memset(&match_value, 0, sizeof(match_value));
+	memset(&action_value, 0, sizeof(action_value));
+
 	mlxsw_sp_erif_match_action_prepare(&match, &action);
 	err = mlxsw_sp_erif_entry_prepare(&entry, &match_value, &match,
 					  &action_value, &action);
-- 
2.9.3
