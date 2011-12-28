From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/5] tcp_diag: Report max ack backlog as separate nla
Date: Wed, 28 Dec 2011 17:37:10 +0400
Message-ID: <4EFB1B86.7090905@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4032 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770Ab1L1NhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 08:37:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since it's thrown away from the core message let's nonetheless report it.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    1 +
 net/ipv4/inet_diag.c      |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index d274712..4cdbfe9 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -108,6 +108,7 @@ enum {
 	INET_DIAG_CONG,
 	INET_DIAG_TOS,
 	INET_DIAG_TCLASS,
+	INET_DIAG_MAX_ACK_BACKLOG,
 };
 
 #define INET_DIAG_MAX INET_DIAG_TCLASS
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 91f9092..8cef079 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -109,6 +109,10 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	r->id.idiag_src[0] = inet->inet_rcv_saddr;
 	r->id.idiag_dst[0] = inet->inet_daddr;
 
+	if (ext & (1 << (INET_DIAG_MAX_ACK_BACKLOG - 1)))
+		RTA_PUT_U8(skb, INET_DIAG_MAX_ACK_BACKLOG,
+				sk->sk_max_ack_backlog);
+
 	/* IPv6 dual-stack sockets use inet->tos for IPv4 connections,
 	 * hence this needs to be included regardless of socket family.
 	 */
-- 
1.5.5.6
