From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH] inet: don't use sk_v6_rcv_saddr directly
Date: Thu, 19 Jan 2017 17:47:46 -0500
Message-ID: <1484866066-25407-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <tom@herbertland.com>,
        <netdev@vger.kernel.org>, <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37746 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751944AbdATAC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 19:02:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When comparing two sockets we need to use inet6_rcv_saddr so we get a NULL
sk_v6_rcv_saddr if the socket isn't AF_INET6, otherwise our comparison function
can be wrong.

Fixes: 637bc8b ("inet: reset tb->fastreuseport when adding a reuseport sk")
Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 net/ipv4/inet_connection_sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 096a085..a336c42 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -99,7 +99,7 @@ int inet_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
 #if IS_ENABLED(CONFIG_IPV6)
 	if (sk->sk_family == AF_INET6)
 		return ipv6_rcv_saddr_equal(&sk->sk_v6_rcv_saddr,
-					    &sk2->sk_v6_rcv_saddr,
+					    inet6_rcv_saddr(sk2),
 					    sk->sk_rcv_saddr,
 					    sk2->sk_rcv_saddr,
 					    ipv6_only_sock(sk),
-- 
2.5.5
