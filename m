From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] ip_tunnel: enclose a code block in macro IS_ENABLED(CONFIG_IPV6)
Date: Mon, 23 May 2016 06:53:51 +0800
Message-ID: <1463957631-11760-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For ipv6 case, enclose the code block in macro IS_ENABLED(CONFIG_IPV6).

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv4/ip_tunnel.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index a69ed94..5f3c8de 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -665,10 +665,13 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		if (skb->protocol == htons(ETH_P_IP)) {
 			tos = inner_iph->tos;
 			connected = false;
-		} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		}
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (skb->protocol == htons(ETH_P_IPV6)) {
 			tos = ipv6_get_dsfield((const struct ipv6hdr *)inner_iph);
 			connected = false;
 		}
+#endif
 	}
 
 	init_tunnel_flow(&fl4, protocol, dst, tnl_params->saddr,
-- 
1.8.3.1
