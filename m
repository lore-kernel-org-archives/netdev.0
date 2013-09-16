From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v3 5/6] ipv6: modify the err to 0 when dealing with, NDISC_REDIRECT
Date: Mon, 16 Sep 2013 19:53:04 +0800
Message-ID: <5236F120.6070205@cn.fujitsu.com>
References: <5236EFEB.60106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:7469 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757281Ab3IPLyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 07:54:04 -0400
In-Reply-To: <5236EFEB.60106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

when dealing with redirect message, the err shoud
be assigned to 0, not EPROTO. And del the statements
for updating route.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/icmp.c | 3 +++
 net/ipv6/raw.c  | 3 +--
 net/ipv6/udp.c  | 2 --
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 4bde43c..6bcedcc 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -975,6 +975,9 @@ int icmpv6_err_convert(u8 type, u8 code, int *err)
 	case ICMPV6_TIME_EXCEED:
 		*err = EHOSTUNREACH;
 		break;
+	case NDISC_REDIRECT:
+		*err = 0;
+		break;
 	}
 
 	return fatal;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 58916bb..baf86b8 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -335,8 +335,7 @@ static void rawv6_err(struct sock *sk, struct sk_buff *skb,
 		ip6_sk_update_pmtu(skb, sk, info);
 		harderr = (np->pmtudisc == IPV6_PMTUDISC_DO);
 	}
-	if (type == NDISC_REDIRECT)
-		ip6_sk_redirect(skb, sk);
+
 	if (np->recverr) {
 		u8 *payload = skb->data;
 		if (!inet->hdrincl)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f405815..a40b392 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -525,8 +525,6 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_sk_update_pmtu(skb, sk, info);
-	if (type == NDISC_REDIRECT)
-		ip6_sk_redirect(skb, sk);
 
 	np = inet6_sk(sk);
 
-- 
1.8.3.1
