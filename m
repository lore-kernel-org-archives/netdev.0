From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 2/2] ping: use ipv6_iface_scope_id() to get scope id
Date: Mon,  3 Jun 2013 13:55:59 +0800
Message-ID: <1370238959-32008-2-git-send-email-amwang@redhat.com>
References: <1370238959-32008-1-git-send-email-amwang@redhat.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069Ab3FCF4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 01:56:13 -0400
In-Reply-To: <1370238959-32008-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

If we don't need scope id, we should initialize it to zero.

Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv4/ping.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 8c92781..b1993b3 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -905,9 +905,8 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		if (np->sndflow)
 			sin6->sin6_flowinfo = ip6_flowinfo(ip6);
 
-		if (__ipv6_addr_needs_scope_id(
-		    ipv6_addr_type(&sin6->sin6_addr)))
-			sin6->sin6_scope_id = IP6CB(skb)->iif;
+		sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
+							  IP6CB(skb)->iif);
 
 		if (inet6_sk(sk)->rxopt.all)
 			pingv6_ops.ip6_datagram_recv_ctl(sk, msg, skb);
-- 
1.7.7.6
