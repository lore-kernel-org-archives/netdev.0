From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 8/8] net/mlx4_core: Fix inaccurate return value of mlx4_flow_attach()
Date: Wed, 14 May 2014 12:15:17 +0300
Message-ID: <1400058917-26313-9-git-send-email-ogerlitz@mellanox.com>
References: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, saeedm@mellanox.com,
	eyalpe@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51162 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752100AbaENJPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 05:15:30 -0400
In-Reply-To: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

Adopt the "info: why not propagate 'ret' from parse_trans_rule()..."
suggestion made by the smatch semantic checker on:
drivers/net/ethernet/mellanox/mlx4/mcg.c:867 mlx4_flow_attach()


Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
1.7.1
