From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v3 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Thu,  8 Jun 2017 12:32:44 +0800
Message-ID: <1496896364-27153-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1496896364-27153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        Alexei Starovoitov <ast@fb.com>
To: "=David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496896364-27153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When __ip6_tnl_rcv fails, the tun_dst won't be freed, so call
dst_release to free it in error code path.

CC: Alexei Starovoitov <ast@fb.com>
Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Changes in v2:
  - Add the the missing Fixes information
Changes in v3:
  - Free tun_dst from error code path
---
 net/ipv6/ip6_tunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9b37f97..ef99d59 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -859,6 +859,8 @@ static int __ip6_tnl_rcv(struct ip6_tnl *tunnel, struct sk_buff *skb,
 	return 0;
 
 drop:
+	if (tun_dst)
+		dst_release((struct dst_entry *)tun_dst);
 	kfree_skb(skb);
 	return 0;
 }
-- 
1.8.3.1
