From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/6] udp: prepare for non BH masking at backlog processing
Date: Wed, 27 Apr 2016 22:25:50 -0700
Message-ID: <1461821152-23200-5-git-send-email-edumazet@google.com>
References: <1461821152-23200-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34979 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcD1F0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 01:26:08 -0400
Received: by mail-pa0-f49.google.com with SMTP id iv1so28045625pac.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 22:26:07 -0700 (PDT)
In-Reply-To: <1461821152-23200-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP uses the generic socket backlog code, and this will soon
be changed to not disable BH when protocol is called back.

We need to use appropriate SNMP accessors.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp.c | 4 ++--
 net/ipv6/udp.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 093284c5c03b..f67f52ba4809 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1514,9 +1514,9 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
-			__UDP_INC_STATS(sock_net(sk), UDP_MIB_RCVBUFERRORS,
+			UDP_INC_STATS(sock_net(sk), UDP_MIB_RCVBUFERRORS,
 					is_udplite);
-		__UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+		UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 		kfree_skb(skb);
 		trace_udp_fail_queue_rcv_skb(rc, sk);
 		return -1;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1ba5a74ac18f..f911c63f79e6 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -570,9 +570,9 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
-			__UDP6_INC_STATS(sock_net(sk),
+			UDP6_INC_STATS(sock_net(sk),
 					 UDP_MIB_RCVBUFERRORS, is_udplite);
-		__UDP6_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+		UDP6_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 		kfree_skb(skb);
 		return -1;
 	}
-- 
2.8.0.rc3.226.g39d4020
