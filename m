From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : tcp_memory_pressure and tcp_socket are__read_mostly
 candidates
Date: Tue, 27 Mar 2007 15:25:13 +0200
Message-ID: <20070327152513.6b82d296.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:59695 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753848AbXC0N26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 09:28:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


tcp_memory_pressure and tcp_socket currently share a cache line with tcp_memory_allocated, tcp_sockets_allocated.
(Very hot cache line)
It makes sense to declare these variables as __read_mostly, to avoid false sharing on SMP.

ffffffff8081d9c0 B tcp_orphan_count
ffffffff8081d9c4 B tcp_memory_allocated
ffffffff8081d9c8 B tcp_sockets_allocated
ffffffff8081d9cc B tcp_memory_pressure
ffffffff8081d9d0 b tcp_md5sig_users
ffffffff8081d9d8 b tcp_md5sig_pool
ffffffff8081d9e0 b warntime.31570
ffffffff8081d9e8 b tcp_socket

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 18a09a7..bb9d91a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -297,7 +297,7 @@ EXPORT_SYMBOL(tcp_sockets_allocated);
  * All the sk_stream_mem_schedule() is of this nature: accounting
  * is strict, actions are advisory and have some latency.
  */
-int tcp_memory_pressure;
+int tcp_memory_pressure __read_mostly;
 
 EXPORT_SYMBOL(tcp_memory_pressure);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a4c46ee..25aec3e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -88,7 +88,7 @@ int sysctl_tcp_low_latency __read_mostly
 #define ICMP_MIN_LENGTH 8
 
 /* Socket used for sending RSTs */
-static struct socket *tcp_socket;
+static struct socket *tcp_socket __read_mostly;
 
 void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
 
