From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH ] net: udp: do not report ICMP redirects to user space
Date: Fri, 20 Sep 2013 18:20:28 +0800
Message-ID: <523C216C.90707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55898 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754246Ab3ITKVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 06:21:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Redirect isn't an error condition, it should leave
the error handler without touching the socket.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/udp.c | 2 +-
 net/ipv6/udp.c | 4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 74d2c95..0ca44df 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -658,7 +658,7 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 		break;
 	case ICMP_REDIRECT:
 		ipv4_sk_redirect(skb, sk);
-		break;
+		goto out;
 	}
 
 	/*
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f405815..72b7eaa 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -525,8 +525,10 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_sk_update_pmtu(skb, sk, info);
-	if (type == NDISC_REDIRECT)
+	if (type == NDISC_REDIRECT) {
 		ip6_sk_redirect(skb, sk);
+		goto out;
+	}
 
 	np = inet6_sk(sk);
 
-- 
1.8.3.1
