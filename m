From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net] ipv6: do not erase dst address with flow label destination
Date: Tue, 10 Dec 2013 15:15:46 +0100
Message-ID: <1386684946-18510-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:49082 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753139Ab3LJOP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 09:15:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is following b579035ff766c9412e2b92abf5cab794bff102b6
	"ipv6: remove old conditions on flow label sharing"

Since there is no reason to restrict a label to a
destination, we should not erase the destination value of a
socket with the value contained in the flow label storage.

This patch allows to really have the same flow label to more
than one destination.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/dccp/ipv6.c     | 1 -
 net/ipv6/datagram.c | 1 -
 net/ipv6/raw.c      | 1 -
 net/ipv6/tcp_ipv6.c | 1 -
 net/ipv6/udp.c      | 1 -
 net/l2tp/l2tp_ip6.c | 1 -
 6 files changed, 6 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4ac71ff..2b90a78 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -851,7 +851,6 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
-			usin->sin6_addr = flowlabel->dst;
 			fl6_sock_release(flowlabel);
 		}
 	}
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 8dfe1f4..93b1aa3 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -73,7 +73,6 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
-			usin->sin6_addr = flowlabel->dst;
 		}
 	}
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 7fb4e14..b6bb87e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -792,7 +792,6 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 				flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 				if (flowlabel == NULL)
 					return -EINVAL;
-				daddr = &flowlabel->dst;
 			}
 		}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7d61263..9a6ca1d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -156,7 +156,6 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
-			usin->sin6_addr = flowlabel->dst;
 			fl6_sock_release(flowlabel);
 		}
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index bcd5699..089c741 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1140,7 +1140,6 @@ do_udp_sendmsg:
 				flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 				if (flowlabel == NULL)
 					return -EINVAL;
-				daddr = &flowlabel->dst;
 			}
 		}
 
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index d9b437e..bb6e206 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -528,7 +528,6 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 				flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 				if (flowlabel == NULL)
 					return -EINVAL;
-				daddr = &flowlabel->dst;
 			}
 		}
 
-- 
1.8.5.1
