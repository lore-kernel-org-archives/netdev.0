From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v3 1/2] ip_tunnel: fix potential issue in ip_tunnel_rcv
Date: Thu,  8 Jun 2017 12:32:43 +0800
Message-ID: <1496896364-27153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        Pravin B Shelar <pshelar@nicira.com>
To: "=David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When ip_tunnel_rcv fails, the tun_dst won't be freed, so call
dst_release to free it in error code path.

CC: Pravin B Shelar <pshelar@nicira.com>
Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Changes in v2:
  - Add the the missing Fixes information
Changes in v3:
  - Free tun_dst from error code path
---
 net/ipv4/ip_tunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index b878ecb..0f1d876 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -446,6 +446,8 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	return 0;
 
 drop:
+	if (tun_dst)
+		dst_release((struct dst_entry *)tun_dst);
 	kfree_skb(skb);
 	return 0;
 }
-- 
1.8.3.1
