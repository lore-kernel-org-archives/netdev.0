From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 8/9] net/mlx4_en: Using positive error value for unsigned
Date: Mon, 12 May 2014 10:43:24 +0300
Message-ID: <1399880605-28772-9-git-send-email-amirv@mellanox.com>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37743 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751862AbaELHnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2014 03:43:49 -0400
In-Reply-To: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

Using a positive value for error: MLX4_NET_TRANS_RULE_NUM instead
of -EPROTONOSUPPORT, to remove compilation warning.


Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4d38a2a..5bb7eda 100644
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
1.8.3.4
