From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 07/30] ipv4: Compute net once in ip_forward_finish
Date: Tue, 15 Sep 2015 20:03:55 -0500
Message-ID: <1442365458-16349-7-git-send-email-ebiederm@xmission.com>
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
 net/ipv4/ip_forward.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index ba2f66b3b3f6..95235c813f18 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -63,10 +63,11 @@ static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
 
 static int ip_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ip_options *opt	= &(IPCB(skb)->opt);
 
-	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
-	IP_ADD_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTOCTETS, skb->len);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_ADD_STATS_BH(net, IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
-- 
2.2.1

