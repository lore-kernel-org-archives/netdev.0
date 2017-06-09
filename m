From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next] ipv6: Initial skb->dev and skb->protocol in ip6_output
Date: Fri,  9 Jun 2017 12:06:07 -0700
Message-ID: <1497035168-9093-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35061 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdFITGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:06:20 -0400
Received: by mail-pf0-f193.google.com with SMTP id u26so9425567pfd.2
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 12:06:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Move the initialization of skb->dev and skb->protocol from
ip6_finish_output2 to ip6_output. This can make the skb->dev and
skb->protocol information avalaible to the CGROUP eBPF filter.

Signed-off-by: Chenbo Feng <fengc@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_output.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index bf8a58a..02cd44f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -67,9 +67,6 @@ static int ip6_finish_output2(struct net *net, struct sock *sk, struct sk_buff *
 	struct in6_addr *nexthop;
 	int ret;
 
-	skb->protocol = htons(ETH_P_IPV6);
-	skb->dev = dev;
-
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr)) {
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
@@ -154,6 +151,9 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	struct net_device *dev = skb_dst(skb)->dev;
 	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
+	skb->protocol = htons(ETH_P_IPV6);
+	skb->dev = dev;
+
 	if (unlikely(idev->cnf.disable_ipv6)) {
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
-- 
2.7.4
