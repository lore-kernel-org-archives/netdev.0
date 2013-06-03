From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v2] ping: always initialize ->sin6_scope_id and ->sin6_flowinfo
Date: Mon,  3 Jun 2013 16:43:52 +0800
Message-ID: <1370249032-14903-1-git-send-email-amwang@redhat.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab3FCIoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 04:44:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

If we don't need scope id, we should initialize it to zero.
Same for ->sin6_flowinfo.

Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv4/ping.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 71f6ad0..0f419a2 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -892,12 +892,12 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		sin6->sin6_port = 0;
 		sin6->sin6_addr = ip6->saddr;
 
+		sin6->sin6_flowinfo = 0;
 		if (np->sndflow)
 			sin6->sin6_flowinfo = ip6_flowinfo(ip6);
 
-		if (__ipv6_addr_needs_scope_id(
-		    ipv6_addr_type(&sin6->sin6_addr)))
-			sin6->sin6_scope_id = IP6CB(skb)->iif;
+		sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
+							  IP6CB(skb)->iif);
 
 		if (inet6_sk(sk)->rxopt.all)
 			pingv6_ops.ip6_datagram_recv_ctl(sk, msg, skb);
