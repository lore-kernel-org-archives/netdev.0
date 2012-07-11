From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net/mlx4: off by one in parse_trans_rule()
Date: Wed, 11 Jul 2012 09:33:36 +0300
Message-ID: <20120711063336.GC11812@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Hadar Hen Zion <hadarh@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:18236 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281Ab2GKGd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 02:33:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should be ">=" here instead of ">".  MLX4_NET_TRANS_RULE_NUM is 6.
We use "spec->id" as an array offset into the __rule_hw_sz[] and
__sw_id_hw[] arrays which have 6 elements.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index bc62f53..5bac0df 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -773,7 +773,7 @@ static int parse_trans_rule(struct mlx4_dev *dev, struct mlx4_spec_list *spec,
 		[MLX4_NET_TRANS_RULE_ID_UDP] =
 			sizeof(struct mlx4_net_trans_rule_hw_tcp_udp)
 	};
-	if (spec->id > MLX4_NET_TRANS_RULE_NUM) {
+	if (spec->id >= MLX4_NET_TRANS_RULE_NUM) {
 		mlx4_err(dev, "Invalid network rule id. id = %d\n", spec->id);
 		return -EINVAL;
 	}
