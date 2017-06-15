From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH 2/2] ip6_tunnel: fix ip6 tunnel lookup in collect_md mode
Date: Fri, 16 Jun 2017 00:37:56 +0800
Message-ID: <1497544676-314-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1497544676-314-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Paolo Abeni <pabeni@redhat.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497544676-314-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In collect_md mode, if the tun dev is down, it still can call
__ip6_tnl_rcv to receive on packets, and the rx statistics increase
improperly.

Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
Cc: Alexei Starovoitov <ast@fb.com>
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv6/ip6_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 6400726..25961c7 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -171,7 +171,7 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 	}
 
 	t = rcu_dereference(ip6n->collect_md_tun);
-	if (t)
+	if (t && (t->dev->flags & IFF_UP))
 		return t;
 
 	t = rcu_dereference(ip6n->tnls_wc[0]);
-- 
1.8.3.1
