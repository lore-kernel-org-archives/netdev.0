From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 18/20] mib: add net to NET_INC_STATS_USER
Date: Wed, 16 Jul 2008 12:34:29 +0400
Message-ID: <487DB295.5000309@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56757 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754273AbYGPIec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:34:32 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h |    2 +-
 net/ipv4/tcp.c   |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 21df167..79d1319 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -163,7 +163,7 @@ DECLARE_SNMP_STAT(struct ipstats_mib, ip_statistics);
 DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(net_statistics, field); } while (0)
 #define NET_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(net_statistics, field); } while (0)
-#define NET_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(net_statistics, field)
+#define NET_INC_STATS_USER(net, field) 	do { (void)net; SNMP_INC_STATS_USER(net_statistics, field); } while (0)
 #define NET_ADD_STATS_BH(field, adnd)	SNMP_ADD_STATS_BH(net_statistics, field, adnd)
 #define NET_ADD_STATS_USER(field, adnd)	SNMP_ADD_STATS_USER(net_statistics, field, adnd)
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9aa4a0e..bbbd2fc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1153,7 +1153,7 @@ static void tcp_prequeue_process(struct sock *sk)
 	struct sk_buff *skb;
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	NET_INC_STATS_USER(LINUX_MIB_TCPPREQUEUED);
+	NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPPREQUEUED);
 
 	/* RX process wants to run with disabled BHs, though it is not
 	 * necessary */
@@ -1793,13 +1793,13 @@ void tcp_close(struct sock *sk, long timeout)
 	 */
 	if (data_was_unread) {
 		/* Unread data was tossed, zap the connection. */
-		NET_INC_STATS_USER(LINUX_MIB_TCPABORTONCLOSE);
+		NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPABORTONCLOSE);
 		tcp_set_state(sk, TCP_CLOSE);
 		tcp_send_active_reset(sk, GFP_KERNEL);
 	} else if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
 		/* Check zero linger _after_ checking for unread data. */
 		sk->sk_prot->disconnect(sk, 0);
-		NET_INC_STATS_USER(LINUX_MIB_TCPABORTONDATA);
+		NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
 	} else if (tcp_close_state(sk)) {
 		/* We FIN if the application ate all the data before
 		 * zapping the connection.
-- 
1.5.5.1

