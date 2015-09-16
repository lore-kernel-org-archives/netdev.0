From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 22/30] ipv6: Cache net in ip6_output
Date: Tue, 15 Sep 2015 20:04:10 -0500
Message-ID: <1442365458-16349-22-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Keep net in a local variable so I can use it in NF_HOOK_COND
when I pass struct net to all of the netfilter hooks.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv6/ip6_output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 12d0166a64cd..8cab909b181e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -135,9 +135,9 @@ int ip6_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
 	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
+	struct net *net = dev_net(dev);
 	if (unlikely(idev->cnf.disable_ipv6)) {
-		IP6_INC_STATS(dev_net(dev), idev,
-			      IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
 		return 0;
 	}
-- 
2.2.1

