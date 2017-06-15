From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 5/6] net/mlx5e: Remove TC header re-write offloading of ip tos
Date: Thu, 15 Jun 2017 23:55:29 +0300
Message-ID: <20170615205530.26674-6-saeedm@mellanox.com>
References: <20170615205530.26674-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52516 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752071AbdFOU4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:56:38 -0400
In-Reply-To: <20170615205530.26674-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Currently the firmware API is partial and allows to offload only
the dscp part of the tos, also, ipv6 support isn't there yet.

As such, remove the offloading option of ipv4 dscp till the FW
APIs are more comprehensive.

Fixes: d79b6df6b10a ('net/mlx5e: Add parsing of TC pedit actions to HW format')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index ec63158ab643..9df9fc0d26f5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -895,7 +895,6 @@ static struct mlx5_fields fields[] = {
 	{MLX5_ACTION_IN_FIELD_OUT_SMAC_15_0,  2, offsetof(struct pedit_headers, eth.h_source[4])},
 	{MLX5_ACTION_IN_FIELD_OUT_ETHERTYPE,  2, offsetof(struct pedit_headers, eth.h_proto)},
 
-	{MLX5_ACTION_IN_FIELD_OUT_IP_DSCP, 1, offsetof(struct pedit_headers, ip4.tos)},
 	{MLX5_ACTION_IN_FIELD_OUT_IP_TTL,  1, offsetof(struct pedit_headers, ip4.ttl)},
 	{MLX5_ACTION_IN_FIELD_OUT_SIPV4,   4, offsetof(struct pedit_headers, ip4.saddr)},
 	{MLX5_ACTION_IN_FIELD_OUT_DIPV4,   4, offsetof(struct pedit_headers, ip4.daddr)},
-- 
2.11.0
