From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/15] mlxsw: spectrum_router: Determine offload status using generic function
Date: Wed,  8 Feb 2017 11:16:37 +0100
Message-ID: <1486549002-2056-11-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35239 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753414AbdBHKQ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:56 -0500
Received: by mail-wm0-f68.google.com with SMTP id u63so32404274wmu.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:56 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The previous patch introduced a generic function to determine whether a
route should be offloaded or not. Make use of it here.

In the future we're going to add more conditions to this test (e.g.,
whether TOS is non-zero), so it makes sense to centralize it instead of
open coding it in a few places.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index acabb35..c452bd3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1696,7 +1696,7 @@ static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
 	 * with provided ECMP size. Otherwise, setup trap and pass
 	 * traffic to kernel.
 	 */
-	if (fib_entry->nh_group->adj_index_valid) {
+	if (mlxsw_sp_fib_entry_should_offload(fib_entry)) {
 		trap_action = MLXSW_REG_RALUE_TRAP_ACTION_NOP;
 		adjacency_index = fib_entry->nh_group->adj_index;
 		ecmp_size = fib_entry->nh_group->ecmp_size;
-- 
2.7.4
