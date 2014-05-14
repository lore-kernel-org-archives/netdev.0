From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 7/8] net/mlx4_en: Using positive error value for unsigned
Date: Wed, 14 May 2014 12:15:16 +0300
Message-ID: <1400058917-26313-8-git-send-email-ogerlitz@mellanox.com>
References: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, saeedm@mellanox.com,
	eyalpe@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51158 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751765AbaENJPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 05:15:30 -0400
In-Reply-To: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

Using a positive value for error: MLX4_NET_TRANS_RULE_NUM instead
of -EPROTONOSUPPORT, to remove compilation warning.


Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9090643..15c8811 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -130,7 +130,7 @@ static enum mlx4_net_trans_rule_id mlx4_ip_proto_to_trans_rule_id(u8 ip_proto)
 	case IPPROTO_TCP:
 		return MLX4_NET_TRANS_RULE_ID_TCP;
 	default:
-		return -EPROTONOSUPPORT;
+		return MLX4_NET_TRANS_RULE_NUM;
 	}
 };
 
@@ -177,7 +177,7 @@ static void mlx4_en_filter_work(struct work_struct *work)
 	int rc;
 	__be64 mac_mask = cpu_to_be64(MLX4_MAC_MASK << 16);
 
-	if (spec_tcp_udp.id < 0) {
+	if (spec_tcp_udp.id >= MLX4_NET_TRANS_RULE_NUM) {
 		en_warn(priv, "RFS: ignoring unsupported ip protocol (%d)\n",
 			filter->ip_proto);
 		goto ignore;
-- 
1.7.1
