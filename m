From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] netlink: use nla_get_in_addr and nla_put_in_addr for ipv4 address
Date: Thu, 31 Mar 2016 18:21:38 +0800
Message-ID: <1459419698-4466-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
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

Since nla_get_in_addr and nla_put_in_addr were implemented,
so use them appropriately.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv4/ip_tunnel_core.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 02dd990..47ea85d 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -247,10 +247,10 @@ static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
 		tun_info->key.tun_id = nla_get_be64(tb[LWTUNNEL_IP_ID]);
 
 	if (tb[LWTUNNEL_IP_DST])
-		tun_info->key.u.ipv4.dst = nla_get_be32(tb[LWTUNNEL_IP_DST]);
+		tun_info->key.u.ipv4.dst = nla_get_in_addr(tb[LWTUNNEL_IP_DST]);
 
 	if (tb[LWTUNNEL_IP_SRC])
-		tun_info->key.u.ipv4.src = nla_get_be32(tb[LWTUNNEL_IP_SRC]);
+		tun_info->key.u.ipv4.src = nla_get_in_addr(tb[LWTUNNEL_IP_SRC]);
 
 	if (tb[LWTUNNEL_IP_TTL])
 		tun_info->key.ttl = nla_get_u8(tb[LWTUNNEL_IP_TTL]);
@@ -275,8 +275,8 @@ static int ip_tun_fill_encap_info(struct sk_buff *skb,
 	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
 
 	if (nla_put_be64(skb, LWTUNNEL_IP_ID, tun_info->key.tun_id) ||
-	    nla_put_be32(skb, LWTUNNEL_IP_DST, tun_info->key.u.ipv4.dst) ||
-	    nla_put_be32(skb, LWTUNNEL_IP_SRC, tun_info->key.u.ipv4.src) ||
+	    nla_put_in_addr(skb, LWTUNNEL_IP_DST, tun_info->key.u.ipv4.dst) ||
+	    nla_put_in_addr(skb, LWTUNNEL_IP_SRC, tun_info->key.u.ipv4.src) ||
 	    nla_put_u8(skb, LWTUNNEL_IP_TOS, tun_info->key.tos) ||
 	    nla_put_u8(skb, LWTUNNEL_IP_TTL, tun_info->key.ttl) ||
 	    nla_put_be16(skb, LWTUNNEL_IP_FLAGS, tun_info->key.tun_flags))
-- 
1.8.3.1
