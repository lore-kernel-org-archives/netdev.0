From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v4 2/2] ip6_tunnel: fix ip6 tunnel lookup in collect_md mode
Date: Tue, 12 Sep 2017 17:47:57 +0800
Message-ID: <1505209677-12728-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1505209677-12728-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        Alexei Starovoitov <ast@fb.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505209677-12728-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In collect_md mode, if the tun dev is down, it still can call
__ip6_tnl_rcv to receive on packets, and the rx statistics increase
improperly.

When the md tunnel is down, it's not neccessary to increase RX drops
for the tunnel device, packets would be recieved on fallback tunnel,
and the RX drops on fallback device will be increased as expected.

Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
Cc: Alexei Starovoitov <ast@fb.com>
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Change since v4:
  * Make the commit message more clearer
  * Fix wrong recipient address
---
 net/ipv6/ip6_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 10a693a..ae73164 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -171,7 +171,7 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 	}
 
 	t = rcu_dereference(ip6n->collect_md_tun);
-	if (t)
+	if (t && t->dev->flags & IFF_UP)
 		return t;
 
 	t = rcu_dereference(ip6n->tnls_wc[0]);
-- 
1.8.3.1
