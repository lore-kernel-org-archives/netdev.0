From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] netfilter: unnecessary to check whether ip6_route_output() returns NULL
Date: Sun,  3 Apr 2016 22:03:33 +0800
Message-ID: <1459692213-3948-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip6_route_output() never returns NULL, so it is not appropriate to
check if the return value is NULL.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv6/netfilter/nf_reject_ipv6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 4709f65..a540022 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -158,7 +158,7 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
 	fl6.fl6_dport = otcph->source;
 	security_skb_classify_flow(oldskb, flowi6_to_flowi(&fl6));
 	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst == NULL || dst->error) {
+	if (dst->error) {
 		dst_release(dst);
 		return;
 	}
-- 
1.8.3.1
