From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 06/15] net/mlx5e: Use macro for TC header re-write offload field mapping
Date: Fri, 23 Jun 2017 17:26:13 +0300
Message-ID: <20170623142622.16565-7-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54049 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753820AbdFWO1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:42 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Use a macro for the static mapping between the enumeration of field
supported by the firmware for header re-write to the corresponding
network header field. This improves the readability of the code and
doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 54 +++++++++++++------------
 1 file changed, 29 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 382dede903a3..0318d6f6e1da 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1058,32 +1058,36 @@ struct mlx5_fields {
 	u32 offset;
 };
 
+#define OFFLOAD(fw_field, size, field, off) \
+		{MLX5_ACTION_IN_FIELD_OUT_ ## fw_field, size, offsetof(struct pedit_headers, field) + (off)}
+
 static struct mlx5_fields fields[] = {
-	{MLX5_ACTION_IN_FIELD_OUT_DMAC_47_16, 4, offsetof(struct pedit_headers, eth.h_dest[0])},
-	{MLX5_ACTION_IN_FIELD_OUT_DMAC_15_0,  2, offsetof(struct pedit_headers, eth.h_dest[4])},
-	{MLX5_ACTION_IN_FIELD_OUT_SMAC_47_16, 4, offsetof(struct pedit_headers, eth.h_source[0])},
-	{MLX5_ACTION_IN_FIELD_OUT_SMAC_15_0,  2, offsetof(struct pedit_headers, eth.h_source[4])},
-	{MLX5_ACTION_IN_FIELD_OUT_ETHERTYPE,  2, offsetof(struct pedit_headers, eth.h_proto)},
-
-	{MLX5_ACTION_IN_FIELD_OUT_IP_TTL,  1, offsetof(struct pedit_headers, ip4.ttl)},
-	{MLX5_ACTION_IN_FIELD_OUT_SIPV4,   4, offsetof(struct pedit_headers, ip4.saddr)},
-	{MLX5_ACTION_IN_FIELD_OUT_DIPV4,   4, offsetof(struct pedit_headers, ip4.daddr)},
-
-	{MLX5_ACTION_IN_FIELD_OUT_SIPV6_127_96, 4, offsetof(struct pedit_headers, ip6.saddr.s6_addr32[0])},
-	{MLX5_ACTION_IN_FIELD_OUT_SIPV6_95_64,  4, offsetof(struct pedit_headers, ip6.saddr.s6_addr32[1])},
-	{MLX5_ACTION_IN_FIELD_OUT_SIPV6_63_32,  4, offsetof(struct pedit_headers, ip6.saddr.s6_addr32[2])},
-	{MLX5_ACTION_IN_FIELD_OUT_SIPV6_31_0,   4, offsetof(struct pedit_headers, ip6.saddr.s6_addr32[3])},
-	{MLX5_ACTION_IN_FIELD_OUT_DIPV6_127_96, 4, offsetof(struct pedit_headers, ip6.daddr.s6_addr32[0])},
-	{MLX5_ACTION_IN_FIELD_OUT_DIPV6_95_64,  4, offsetof(struct pedit_headers, ip6.daddr.s6_addr32[1])},
-	{MLX5_ACTION_IN_FIELD_OUT_DIPV6_63_32,  4, offsetof(struct pedit_headers, ip6.daddr.s6_addr32[2])},
-	{MLX5_ACTION_IN_FIELD_OUT_DIPV6_31_0,   4, offsetof(struct pedit_headers, ip6.daddr.s6_addr32[3])},
-
-	{MLX5_ACTION_IN_FIELD_OUT_TCP_SPORT, 2, offsetof(struct pedit_headers, tcp.source)},
-	{MLX5_ACTION_IN_FIELD_OUT_TCP_DPORT, 2, offsetof(struct pedit_headers, tcp.dest)},
-	{MLX5_ACTION_IN_FIELD_OUT_TCP_FLAGS, 1, offsetof(struct pedit_headers, tcp.ack_seq) + 5},
-
-	{MLX5_ACTION_IN_FIELD_OUT_UDP_SPORT, 2, offsetof(struct pedit_headers, udp.source)},
-	{MLX5_ACTION_IN_FIELD_OUT_UDP_DPORT, 2, offsetof(struct pedit_headers, udp.dest)},
+	OFFLOAD(DMAC_47_16, 4, eth.h_dest[0], 0),
+	OFFLOAD(DMAC_47_16, 4, eth.h_dest[0], 0),
+	OFFLOAD(DMAC_15_0,  2, eth.h_dest[4], 0),
+	OFFLOAD(SMAC_47_16, 4, eth.h_source[0], 0),
+	OFFLOAD(SMAC_15_0,  2, eth.h_source[4], 0),
+	OFFLOAD(ETHERTYPE,  2, eth.h_proto, 0),
+
+	OFFLOAD(IP_TTL, 1, ip4.ttl,   0),
+	OFFLOAD(SIPV4,  4, ip4.saddr, 0),
+	OFFLOAD(DIPV4,  4, ip4.daddr, 0),
+
+	OFFLOAD(SIPV6_127_96, 4, ip6.saddr.s6_addr32[0], 0),
+	OFFLOAD(SIPV6_95_64,  4, ip6.saddr.s6_addr32[1], 0),
+	OFFLOAD(SIPV6_63_32,  4, ip6.saddr.s6_addr32[2], 0),
+	OFFLOAD(SIPV6_31_0,   4, ip6.saddr.s6_addr32[3], 0),
+	OFFLOAD(DIPV6_127_96, 4, ip6.daddr.s6_addr32[0], 0),
+	OFFLOAD(DIPV6_95_64,  4, ip6.daddr.s6_addr32[1], 0),
+	OFFLOAD(DIPV6_63_32,  4, ip6.daddr.s6_addr32[2], 0),
+	OFFLOAD(DIPV6_31_0,   4, ip6.daddr.s6_addr32[3], 0),
+
+	OFFLOAD(TCP_SPORT, 2, tcp.source,  0),
+	OFFLOAD(TCP_DPORT, 2, tcp.dest,    0),
+	OFFLOAD(TCP_FLAGS, 1, tcp.ack_seq, 5),
+
+	OFFLOAD(UDP_SPORT, 2, udp.source, 0),
+	OFFLOAD(UDP_DPORT, 2, udp.dest,   0),
 };
 
 /* On input attr->num_mod_hdr_actions tells how many HW actions can be parsed at
-- 
2.11.0
