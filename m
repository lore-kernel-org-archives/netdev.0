From: Tom Marshall <tom@cyngn.com>
Subject: [PATCH] net: ip: Do not allow connection to remote port zero
Date: Wed, 11 Feb 2015 16:58:45 -0800
Message-ID: <20150212005844.GB3829@nwwn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:55440 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbbBLA6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 19:58:48 -0500
Received: by mail-pa0-f43.google.com with SMTP id fa1so7589382pad.2
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 16:58:48 -0800 (PST)
Received: from localhost (70-90-190-81-WA.hfc.comcastbusiness.net. [70.90.190.81])
        by mx.google.com with ESMTPSA id n4sm2030573pdl.12.2015.02.11.16.58.46
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 16:58:47 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port zero is reserved according to IANA.

Note UDP sendto is already disallowed if dport is zero.

Signed-off-by: Tom Marshall <tom@cyngn.com>
---
 net/ipv4/datagram.c | 3 +++
 net/ipv4/tcp_ipv4.c | 3 +++
 net/ipv6/datagram.c | 3 +++
 net/ipv6/tcp_ipv6.c | 3 +++
 4 files changed, 12 insertions(+)

diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 90c0e83..e732382 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -37,6 +37,9 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (usin->sin_family != AF_INET)
 		return -EAFNOSUPPORT;
 
+	if (!usin->sin_port)
+		return -EINVAL;
+
 	sk_dst_reset(sk);
 
 	lock_sock(sk);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d22f544..fef2f9f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -156,6 +156,9 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (usin->sin_family != AF_INET)
 		return -EAFNOSUPPORT;
 
+	if (!usin->sin_port)
+		return -EINVAL;
+
 	nexthop = daddr = usin->sin_addr.s_addr;
 	inet_opt = rcu_dereference_protected(inet->inet_opt,
 					     sock_owned_by_user(sk));
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 49f5e73..fb6934e 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -66,6 +66,9 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (usin->sin6_family != AF_INET6)
 		return -EAFNOSUPPORT;
 
+	if (!usin->sin6_port)
+		return -EINVAL;
+
 	memset(&fl6, 0, sizeof(fl6));
 	if (np->sndflow) {
 		fl6.flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9c0b54e..1ae8bf1 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -146,6 +146,9 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (usin->sin6_family != AF_INET6)
 		return -EAFNOSUPPORT;
 
+	if (!usin->sin6_port)
+		return -EINVAL;
+
 	memset(&fl6, 0, sizeof(fl6));
 
 	if (np->sndflow) {
-- 
2.1.4
