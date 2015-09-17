From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH next 31/30] netfilter: Add blank lines in callers of netfilter hooks
Date: Thu, 17 Sep 2015 17:21:31 -0500
Message-ID: <87io78wutw.fsf@x220.int.ebiederm.org>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 15 Sep 2015 19:59:49 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In code review it was noticed that I had failed to add some blank lines
in places where they are customarily used.  Taking a second look at the
code I have to agree blank lines would be nice so I have added them
here.

Reported-by:  Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/xfrm4_output.c | 1 +
 net/ipv6/ip6_output.c   | 1 +
 net/ipv6/xfrm6_output.c | 1 +
 net/xfrm/xfrm_output.c  | 1 +
 4 files changed, 4 insertions(+)

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 28ae2048b93a..cd6be736e19f 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -97,6 +97,7 @@ static int __xfrm4_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 int xfrm4_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
+
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
 			    net, sk, skb, NULL, skb_dst(skb)->dev,
 			    __xfrm4_output,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d8d68e81d123..291a07be5dfb 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -136,6 +136,7 @@ int ip6_output(struct sock *sk, struct sk_buff *skb)
 	struct net_device *dev = skb_dst(skb)->dev;
 	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 	struct net *net = dev_net(dev);
+
 	if (unlikely(idev->cnf.disable_ipv6)) {
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 68a996f8a044..0c3e9ffcf231 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -169,6 +169,7 @@ static int __xfrm6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 int xfrm6_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
+
 	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
 			    net, sk, skb,  NULL, skb_dst(skb)->dev,
 			    __xfrm6_output,
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 61ba99f61dc8..c48a4b8582bb 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -132,6 +132,7 @@ out:
 int xfrm_output_resume(struct sk_buff *skb, int err)
 {
 	struct net *net = xs_net(skb_dst(skb)->xfrm);
+
 	while (likely((err = xfrm_output_one(skb, err)) == 0)) {
 		nf_reset(skb);
 
-- 
2.2.1

