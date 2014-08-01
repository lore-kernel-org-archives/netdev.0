From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] net: use inet6_iif instead of IP6CB()->iif
Date: Fri, 1 Aug 2014 09:52:58 +0800
Message-ID: <53DAF2FA.50706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:48326 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751120AbaHABxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 21:53:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/ping.c     | 2 +-
 net/ipv6/raw.c      | 8 ++++----
 net/ipv6/udp.c      | 2 +-
 net/l2tp/l2tp_ip6.c | 2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 044a0dd..a3c59a0 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -911,7 +911,7 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				sin6->sin6_flowinfo = ip6_flowinfo(ip6);
 			sin6->sin6_scope_id =
 				ipv6_iface_scope_id(&sin6->sin6_addr,
-						    IP6CB(skb)->iif);
+						    inet6_iif(skb));
 			*addr_len = sizeof(*sin6);
 		}
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index dee80fb..39d4422 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -176,7 +176,7 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 		goto out;
 
 	net = dev_net(skb->dev);
-	sk = __raw_v6_lookup(net, sk, nexthdr, daddr, saddr, IP6CB(skb)->iif);
+	sk = __raw_v6_lookup(net, sk, nexthdr, daddr, saddr, inet6_iif(skb));
 
 	while (sk) {
 		int filtered;
@@ -220,7 +220,7 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 			}
 		}
 		sk = __raw_v6_lookup(net, sk_next(sk), nexthdr, daddr, saddr,
-				     IP6CB(skb)->iif);
+				     inet6_iif(skb));
 	}
 out:
 	read_unlock(&raw_v6_hashinfo.lock);
@@ -375,7 +375,7 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 		net = dev_net(skb->dev);
 
 		while ((sk = __raw_v6_lookup(net, sk, nexthdr, saddr, daddr,
-						IP6CB(skb)->iif))) {
+						inet6_iif(skb)))) {
 			rawv6_err(sk, skb, NULL, type, code,
 					inner_offset, info);
 			sk = sk_next(sk);
@@ -506,7 +506,7 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 		sin6->sin6_addr = ipv6_hdr(skb)->saddr;
 		sin6->sin6_flowinfo = 0;
 		sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
-							  IP6CB(skb)->iif);
+							  inet6_iif(skb));
 		*addr_len = sizeof(*sin6);
 	}
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5b6091d..5559fab 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -472,7 +472,7 @@ try_again:
 			sin6->sin6_addr = ipv6_hdr(skb)->saddr;
 			sin6->sin6_scope_id =
 				ipv6_iface_scope_id(&sin6->sin6_addr,
-						    IP6CB(skb)->iif);
+						    inet6_iif(skb));
 		}
 		*addr_len = sizeof(*sin6);
 	}
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index f3f98a1..0edb263 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -687,7 +687,7 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 		lsa->l2tp_scope_id = 0;
 		lsa->l2tp_conn_id = 0;
 		if (ipv6_addr_type(&lsa->l2tp_addr) & IPV6_ADDR_LINKLOCAL)
-			lsa->l2tp_scope_id = IP6CB(skb)->iif;
+			lsa->l2tp_scope_id = inet6_iif(skb);
 	}
 
 	if (np->rxopt.all)
-- 
1.8.3.1
