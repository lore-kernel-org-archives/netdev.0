From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum_flower: Remove bogus warns in mlxsw_sp_flower_destroy
Date: Mon,  6 Mar 2017 21:22:09 +0100
Message-ID: <1488831729-4438-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33072 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932156AbdCFU37 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 15:29:59 -0500
Received: by mail-wr0-f193.google.com with SMTP id g10so23170941wrg.0
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 12:29:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This warnings may be hit even in case they should not - in case user
puts a TC-flower rule which failed to be offloaded. So just remove them.

Reported-by: Petr Machata <petrm@mellanox.com>
Reported-by: Ido Schimmel <idosch@mellanox.com>
Fixes: commit 7aa0f5aa9030 ("mlxsw: spectrum: Implement TC flower offload")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 22ab429..ae6cccc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -303,11 +303,11 @@ void mlxsw_sp_flower_destroy(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 	ruleset = mlxsw_sp_acl_ruleset_get(mlxsw_sp, mlxsw_sp_port->dev,
 					   ingress,
 					   MLXSW_SP_ACL_PROFILE_FLOWER);
-	if (WARN_ON(IS_ERR(ruleset)))
+	if (IS_ERR(ruleset))
 		return;
 
 	rule = mlxsw_sp_acl_rule_lookup(mlxsw_sp, ruleset, f->cookie);
-	if (!WARN_ON(!rule)) {
+	if (rule) {
 		mlxsw_sp_acl_rule_del(mlxsw_sp, rule);
 		mlxsw_sp_acl_rule_destroy(mlxsw_sp, rule);
 	}
-- 
2.7.4
