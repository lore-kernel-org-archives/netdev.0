From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH 11/11] ipv6: move route updating for redirect to ndisc layer
Date: Thu, 12 Sep 2013 18:52:24 +0800
Message-ID: <52319CE8.4080407@cn.fujitsu.com>
References: <52319A6E.6090503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:29561 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753026Ab3ILKxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 06:53:20 -0400
In-Reply-To: <52319A6E.6090503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

And when dealing with the redirect message, the err
should be assigned to 0.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/udp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f405815..d212c62 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -525,8 +525,6 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_sk_update_pmtu(skb, sk, info);
-	if (type == NDISC_REDIRECT)
-		ip6_sk_redirect(skb, sk);
 
 	np = inet6_sk(sk);
 
@@ -536,6 +534,8 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (sk->sk_state != TCP_ESTABLISHED && !np->recverr)
 		goto out;
 
+	if (type == NDISC_REDIRECT)
+		err = 0;
 	if (np->recverr)
 		ipv6_icmp_error(sk, skb, err, uh->dest, ntohl(info), (u8 *)(uh+1));
 
-- 
1.8.3.1
