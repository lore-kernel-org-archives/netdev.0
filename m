From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Subject: [PATCH net-next v2 4/5] net: l2tp: cleanup: remove redundant condition
Date: Mon,  7 Nov 2016 20:39:27 +0000
Message-ID: <20161107203928.30111-4-asbjorn@asbjorn.st>
References: <20161107203928.30111-1-asbjorn@asbjorn.st>
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161107203928.30111-1-asbjorn@asbjorn.st>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These assignments follow this pattern:

	unsigned int foo:1;
	struct nlattr *nla = info->attrs[bar];

	if (nla)
		foo = nla_get_flag(nla); /* expands to: foo = !!nla */

This could be simplified to: if (nla) foo = 1;
but lets just remove the condition and use the macro,

	foo = nla_get_flag(nla);

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
---
 net/l2tp/l2tp_netlink.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 494910d..3620fba 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -220,14 +220,14 @@ static int l2tp_nl_cmd_tunnel_create(struct sk_buff *skb, struct genl_info *info
 			cfg.local_udp_port = nla_get_u16(info->attrs[L2TP_ATTR_UDP_SPORT]);
 		if (info->attrs[L2TP_ATTR_UDP_DPORT])
 			cfg.peer_udp_port = nla_get_u16(info->attrs[L2TP_ATTR_UDP_DPORT]);
-		if (info->attrs[L2TP_ATTR_UDP_CSUM])
-			cfg.use_udp_checksums = nla_get_flag(info->attrs[L2TP_ATTR_UDP_CSUM]);
+		cfg.use_udp_checksums = nla_get_flag(
+			info->attrs[L2TP_ATTR_UDP_CSUM]);
 
 #if IS_ENABLED(CONFIG_IPV6)
-		if (info->attrs[L2TP_ATTR_UDP_ZERO_CSUM6_TX])
-			cfg.udp6_zero_tx_checksums = nla_get_flag(info->attrs[L2TP_ATTR_UDP_ZERO_CSUM6_TX]);
-		if (info->attrs[L2TP_ATTR_UDP_ZERO_CSUM6_RX])
-			cfg.udp6_zero_rx_checksums = nla_get_flag(info->attrs[L2TP_ATTR_UDP_ZERO_CSUM6_RX]);
+		cfg.udp6_zero_tx_checksums = nla_get_flag(
+			info->attrs[L2TP_ATTR_UDP_ZERO_CSUM6_TX]);
+		cfg.udp6_zero_rx_checksums = nla_get_flag(
+			info->attrs[L2TP_ATTR_UDP_ZERO_CSUM6_RX]);
 #endif
 	}
 
-- 
2.10.1
