From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 07/15] net/mlx5e: Add header re-write offloading of IPv6 hop-limit
Date: Fri, 23 Jun 2017 17:26:14 +0300
Message-ID: <20170623142622.16565-8-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54056 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754048AbdFWO1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:42 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

For environments where flow-based ipv6 router is offloaded.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 1 +
 include/linux/mlx5/mlx5_ifc.h                   | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 0318d6f6e1da..3c536f560dd2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1081,6 +1081,7 @@ static struct mlx5_fields fields[] = {
 	OFFLOAD(DIPV6_95_64,  4, ip6.daddr.s6_addr32[1], 0),
 	OFFLOAD(DIPV6_63_32,  4, ip6.daddr.s6_addr32[2], 0),
 	OFFLOAD(DIPV6_31_0,   4, ip6.daddr.s6_addr32[3], 0),
+	OFFLOAD(IPV6_HOPLIMIT, 1, ip6.hop_limit, 0),
 
 	OFFLOAD(TCP_SPORT, 2, tcp.source,  0),
 	OFFLOAD(TCP_DPORT, 2, tcp.dest,    0),
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 694f51d388d9..4b547f551a2e 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -4620,6 +4620,7 @@ enum {
 	MLX5_ACTION_IN_FIELD_OUT_DIPV6_31_0    = 0x14,
 	MLX5_ACTION_IN_FIELD_OUT_SIPV4         = 0x15,
 	MLX5_ACTION_IN_FIELD_OUT_DIPV4         = 0x16,
+	MLX5_ACTION_IN_FIELD_OUT_IPV6_HOPLIMIT = 0x47,
 };
 
 struct mlx5_ifc_alloc_modify_header_context_out_bits {
-- 
2.11.0
