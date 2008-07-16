From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 16/20] mib: add net to NET_INC_STATS
Date: Wed, 16 Jul 2008 12:32:37 +0400
Message-ID: <487DB225.10808@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56745 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754533AbYGPIck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:32:40 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h      |    2 +-
 net/ipv4/tcp.c        |    2 +-
 net/ipv4/tcp_output.c |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 93d0e09..b42a434 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -161,7 +161,7 @@ DECLARE_SNMP_STAT(struct ipstats_mib, ip_statistics);
 #define IP_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(ip_statistics, field); } while (0)
 #define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH(ip_statistics, field, val)
 DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
-#define NET_INC_STATS(field)		SNMP_INC_STATS(net_statistics, field)
+#define NET_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(net_statistics, field); } while (0)
 #define NET_INC_STATS_BH(field)		SNMP_INC_STATS_BH(net_statistics, field)
 #define NET_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(net_statistics, field)
 #define NET_ADD_STATS_BH(field, adnd)	SNMP_ADD_STATS_BH(net_statistics, field, adnd)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 44b2fda..9c420da 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -319,7 +319,7 @@ EXPORT_SYMBOL(tcp_memory_pressure);
 void tcp_enter_memory_pressure(struct sock *sk)
 {
 	if (!tcp_memory_pressure) {
-		NET_INC_STATS(LINUX_MIB_TCPMEMORYPRESSURES);
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
 		tcp_memory_pressure = 1;
 	}
 }
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c3b0da8..176f070 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2119,7 +2119,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	/* NOTE: No TCP options attached and we never retransmit this. */
 	skb = alloc_skb(MAX_TCP_HEADER, priority);
 	if (!skb) {
-		NET_INC_STATS(LINUX_MIB_TCPABORTFAILED);
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
 		return;
 	}
 
@@ -2130,7 +2130,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	/* Send it off. */
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	if (tcp_transmit_skb(sk, skb, 0, priority))
-		NET_INC_STATS(LINUX_MIB_TCPABORTFAILED);
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
 
 	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTRSTS);
 }
-- 
1.5.5.1

