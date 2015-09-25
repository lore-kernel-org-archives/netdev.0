From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/8] net/mlx5_core: Fix async commands return code
Date: Fri, 25 Sep 2015 10:49:12 +0300
Message-ID: <1443167356-32095-5-git-send-email-ogerlitz@mellanox.com>
References: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, eli@labmailer.mlnx,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eli Cohen <eli@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39323 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753891AbbIYHuB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 03:50:01 -0400
In-Reply-To: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

In case of async command completion, the error code returned should take
into account the command completion status.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 75ff58d..c351659 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1136,6 +1136,7 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, unsigned long vector)
 				mlx5_free_cmd_msg(dev, ent->out);
 				free_msg(dev, ent->in);
 
+				err = err ? err : ent->status;
 				free_cmd(ent);
 				callback(err, context);
 			} else {
-- 
2.3.7
