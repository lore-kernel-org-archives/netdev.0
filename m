From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 11/13] net/mlx5: E-Switch, always set mc_promisc for allmulti vports
Date: Fri, 10 Jun 2016 00:07:38 +0300
Message-ID: <1465506460-1854-12-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34515 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751871AbcFIVJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:09:59 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Set the mc_promisc flag also in the case of adding new mc address to
existing allmulti vport.

Fixes: a35f71f27a61 ('net/mlx5: E-Switch, Implement promiscuous rx modes vf request handling')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 9b1855b..aebbd6c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -651,6 +651,7 @@ static void update_allmulti_vports(struct mlx5_eswitch *esw,
 					esw_fdb_set_vport_rule(esw,
 							       mac,
 							       vport_idx);
+			iter_vaddr->mc_promisc = true;
 			break;
 		case MLX5_ACTION_DEL:
 			if (!iter_vaddr)
-- 
2.8.0
