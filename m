From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next] Revert "ipv6: Initial skb->dev and skb->protocol in ip6_output"
Date: Fri,  9 Jun 2017 12:56:02 -0700
Message-ID: <1497038162-10327-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34568 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751538AbdFIT4S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:56:18 -0400
Received: by mail-pg0-f67.google.com with SMTP id v14so8529965pgn.1
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 12:56:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

This reverts commit 97a7a37a7b7b("ipv6: Initial skb->dev and
skb->protocol in ip6_output") since it does not handles the
skb->dev assignment inside ip6_fragment() code path properly.
Need to rework and upload again

Fixes: 97a7a37a7b7b("ipv6: Initial skb->dev and skb->protocol in ip6_output")
Signed-off-by: Chenbo Feng <fengc@google.com>
---
 net/ipv6/ip6_output.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 02cd44f..bf8a58a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -67,6 +67,9 @@ static int ip6_finish_output2(struct net *net, struct sock *sk, struct sk_buff *
 	struct in6_addr *nexthop;
 	int ret;
 
+	skb->protocol = htons(ETH_P_IPV6);
+	skb->dev = dev;
+
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr)) {
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
@@ -151,9 +154,6 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	struct net_device *dev = skb_dst(skb)->dev;
 	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
-	skb->protocol = htons(ETH_P_IPV6);
-	skb->dev = dev;
-
 	if (unlikely(idev->cnf.disable_ipv6)) {
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
-- 
2.7.4
