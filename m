From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] ipv6: Remove some pointless conditionals before kfree_skb()
Date: Tue, 24 Feb 2009 15:45:33 +0800
Message-ID: <49A3A59D.9090102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50165 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751307AbZBXHqH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 02:46:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

The semantic match that finds the problem is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
expression E;
@@
- if (E)
- 	kfree_skb(E);
+ kfree_skb(E);
// </smpl>

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv6/ipv6_sockglue.c |    3 +--
 net/ipv6/tcp_ipv6.c      |    6 ++----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 40f3246..d31df0f 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -218,8 +218,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			if (opt)
 				sock_kfree_s(sk, opt, opt->tot_len);
 			pktopt = xchg(&np->pktoptions, NULL);
-			if (pktopt)
-				kfree_skb(pktopt);
+			kfree_skb(pktopt);
 
 			sk->sk_destruct = inet_sock_destruct;
 			/*
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e5b85d4..273a5dd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -533,8 +533,7 @@ static inline void syn_flood_warning(struct sk_buff *skb)
 
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
 {
-	if (inet6_rsk(req)->pktopts)
-		kfree_skb(inet6_rsk(req)->pktopts);
+	kfree_skb(inet6_rsk(req)->pktopts);
 }
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -1611,8 +1610,7 @@ ipv6_pktoptions:
 		}
 	}
 
-	if (opt_skb)
-		kfree_skb(opt_skb);
+	kfree_skb(opt_skb);
 	return 0;
 }
 
-- 
1.5.3.8




