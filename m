From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Fix error message deprecation for ConnectX-2 cards
Date: Sun,  5 Apr 2015 17:50:48 +0300
Message-ID: <1428245448-24191-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:38020 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751923AbbDEOvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Apr 2015 10:51:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Commit 1daa4303b4ca ("net/mlx4_core: Deprecate error message at
ConnectX-2 cards startup to debug") did the deprecation only for port 1
of the card. Need to deprecate for port 2 as well.

Fixes: 1daa4303b4ca ("net/mlx4_core: Deprecate error message at ConnectX-2 cards startup to debug")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
Hi Dave,

This patch fixes a bug that introduced in kernel 3.18 (see Fixes tag). Please
push it into -stable

Thanks,
Amir


 drivers/net/ethernet/mellanox/mlx4/cmd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 3350721..546ca42 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -724,7 +724,8 @@ static int mlx4_cmd_wait(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 		 * on the host, we deprecate the error message for this
 		 * specific command/input_mod/opcode_mod/fw-status to be debug.
 		 */
-		if (op == MLX4_CMD_SET_PORT && in_modifier == 1 &&
+		if (op == MLX4_CMD_SET_PORT &&
+		    (in_modifier == 1 || in_modifier == 2) &&
 		    op_modifier == 0 && context->fw_status == CMD_STAT_BAD_SIZE)
 			mlx4_dbg(dev, "command 0x%x failed: fw status = 0x%x\n",
 				 op, context->fw_status);
-- 
1.9.3
