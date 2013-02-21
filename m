From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv4: fix a bug in ping_err().
Date: Thu, 21 Feb 2013 18:09:54 +0800
Message-ID: <1361441394-16668-1-git-send-email-lw@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, lw@cn.fujitsu.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:28943 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751392Ab3BUKMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2013 05:12:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should get 'type' and 'code' from the outer ICMP header.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv4/ping.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 55c4ee1..2e91006 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -322,8 +322,8 @@ void ping_err(struct sk_buff *skb, u32 info)
 	struct iphdr *iph = (struct iphdr *)skb->data;
 	struct icmphdr *icmph = (struct icmphdr *)(skb->data+(iph->ihl<<2));
 	struct inet_sock *inet_sock;
-	int type = icmph->type;
-	int code = icmph->code;
+	int type = icmp_hdr(skb)->type;
+	int code = icmp_hdr(skb)->code;
 	struct net *net = dev_net(skb->dev);
 	struct sock *sk;
 	int harderr;
-- 
1.8.0.2
