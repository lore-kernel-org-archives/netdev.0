From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH 1/2] ip_tunnel: fix setting ttl and tos value in collect_md mode
Date: Thu,  7 Sep 2017 14:08:34 +0800
Message-ID: <1504764515-13536-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        Alexei Starovoitov <ast@fb.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ttl and tos variables are declared and assigned, but are not used in
iptunnel_xmit() function.

Fixes: cfc7381b3002 ("ip_tunnel: add collect_md mode to IPIP tunnel")
Cc: Alexei Starovoitov <ast@fb.com>
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv4/ip_tunnel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 129d1a3..e1856bf 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -618,8 +618,8 @@ void ip_md_tunnel_xmit(struct sk_buff *skb, struct net_device *dev, u8 proto)
 		ip_rt_put(rt);
 		goto tx_dropped;
 	}
-	iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr, proto, key->tos,
-		      key->ttl, df, !net_eq(tunnel->net, dev_net(dev)));
+	iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr, proto, tos, ttl,
+		      df, !net_eq(tunnel->net, dev_net(dev)));
 	return;
 tx_error:
 	dev->stats.tx_errors++;
-- 
1.8.3.1
