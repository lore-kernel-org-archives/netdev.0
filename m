From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 12/20] mib: add net to TCP_ADD_STATS_USER
Date: Wed, 16 Jul 2008 12:24:38 +0400
Message-ID: <487DB046.3060608@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35651 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756131AbYGPIYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:24:44 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we're done with the TCP_XXX_STATS macros.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/tcp.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 92d8769..4d78818 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -269,7 +269,7 @@ DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 #define TCP_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(tcp_statistics, field); } while (0)
 #define TCP_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(tcp_statistics, field); } while (0)
 #define TCP_DEC_STATS(net, field)	do { (void)net; SNMP_DEC_STATS(tcp_statistics, field); } while (0)
-#define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
+#define TCP_ADD_STATS_USER(net, field, val) do { (void)net; SNMP_ADD_STATS_USER(tcp_statistics, field, val); } while (0)
 
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
 
@@ -1027,10 +1027,10 @@ static inline int tcp_paws_check(const struct tcp_options_received *rx_opt, int
 static inline void tcp_mib_init(struct net *net)
 {
 	/* See RFC 2012 */
-	TCP_ADD_STATS_USER(TCP_MIB_RTOALGORITHM, 1);
-	TCP_ADD_STATS_USER(TCP_MIB_RTOMIN, TCP_RTO_MIN*1000/HZ);
-	TCP_ADD_STATS_USER(TCP_MIB_RTOMAX, TCP_RTO_MAX*1000/HZ);
-	TCP_ADD_STATS_USER(TCP_MIB_MAXCONN, -1);
+	TCP_ADD_STATS_USER(net, TCP_MIB_RTOALGORITHM, 1);
+	TCP_ADD_STATS_USER(net, TCP_MIB_RTOMIN, TCP_RTO_MIN*1000/HZ);
+	TCP_ADD_STATS_USER(net, TCP_MIB_RTOMAX, TCP_RTO_MAX*1000/HZ);
+	TCP_ADD_STATS_USER(net, TCP_MIB_MAXCONN, -1);
 }
 
 /* from STCP */
-- 
1.5.5.1

