From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 16/30] ipv6: Only compute net once in ip6mr_forward2_finish
Date: Tue, 15 Sep 2015 20:04:04 -0500
Message-ID: <1442365458-16349-16-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv6/ip6mr.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index e95f6b6281de..3e3085b37a91 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1987,9 +1987,10 @@ int ip6mr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 
 static inline int ip6mr_forward2_finish(struct sock *sk, struct sk_buff *skb)
 {
-	IP6_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(skb)),
+	struct net *net = dev_net(skb_dst(skb)->dev);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 			 IPSTATS_MIB_OUTFORWDATAGRAMS);
-	IP6_ADD_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(skb)),
+	IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 			 IPSTATS_MIB_OUTOCTETS, skb->len);
 	return dst_output(sk, skb);
 }
-- 
2.2.1

