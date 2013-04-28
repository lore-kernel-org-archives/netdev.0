From: David Rientjes <rientjes@google.com>
Subject: [patch] net, ipv4: fix link error when CONFIG_IPV6 is a module
Date: Sun, 28 Apr 2013 14:08:41 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1304281407310.3194@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/built-in.o: In function `ip_tunnel_xmit':
(.text+0x11ec70): undefined reference to `icmpv6_send'

Signed-off-by: David Rientjes <rientjes@google.com>
---
 net/ipv4/ip_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -600,7 +600,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 			goto tx_error;
 		}
 	}
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_BUILTIN(CONFIG_IPV6)
 	else if (skb->protocol == htons(ETH_P_IPV6)) {
 		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
 
