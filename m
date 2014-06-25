From: James M Leddy <james.leddy@redhat.com>
Subject: [PATCH v2] udp: Add MIB counters for rcvbuferrors
Date: Wed, 25 Jun 2014 17:33:53 -0400
Message-ID: <1403732033-32123-1-git-send-email-james.leddy@redhat.com>
Cc: James M Leddy <james.leddy@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181AbaFYVeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 17:34:12 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s5PLYBnt002128
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 17:34:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MIB counters for rcvbuferrors in UDP to help diagnose problems.

Signed-off-by: James M Leddy <james.leddy@redhat.com>
---
 net/ipv4/udp.c |    5 ++++-
 net/ipv6/udp.c |    6 +++++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d92f94b..7d5a866 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1588,8 +1588,11 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		goto csum_error;
 
 
-	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf))
+	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf)) {
+		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
+				 is_udplite);
 		goto drop;
+	}
 
 	rc = 0;
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 95c8347..7092ff7 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -674,8 +674,11 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 			goto csum_error;
 	}
 
-	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf))
+	if (sk_rcvqueues_full(sk, skb, sk->sk_rcvbuf)) {
+		UDP6_INC_STATS_BH(sock_net(sk),
+				  UDP_MIB_RCVBUFERRORS, is_udplite);
 		goto drop;
+	}
 
 	skb_dst_drop(skb);
 
@@ -690,6 +693,7 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	bh_unlock_sock(sk);
 
 	return rc;
+
 csum_error:
 	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 drop:
-- 
1.7.1
