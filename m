From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 9/9] net/mlx4_core: Fix inaccurate return value of mlx4_flow_attach()
Date: Mon, 12 May 2014 10:43:25 +0300
Message-ID: <1399880605-28772-10-git-send-email-amirv@mellanox.com>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59203 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752566AbaELHnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2014 03:43:50 -0400
In-Reply-To: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

Adopt the "info: why not propagate 'ret' from parse_trans_rule()..."
suggestion made by the smatch semantic checker on:
drivers/net/ethernet/mellanox/mlx4/mcg.c:867 mlx4_flow_attach()


Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 7c6eba6..4c36def 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -897,7 +897,7 @@ int mlx4_flow_attach(struct mlx4_dev *dev,
 		ret = parse_trans_rule(dev, cur, mailbox->buf + size);
 		if (ret < 0) {
 			mlx4_free_cmd_mailbox(dev, mailbox);
-			return -EINVAL;
+			return ret;
 		}
 		size += ret;
 	}
-- 
1.8.3.4
