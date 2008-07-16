From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 11/20] mib: add net to TCP_DEC_STATS
Date: Wed, 16 Jul 2008 12:23:33 +0400
Message-ID: <487DB005.9050503@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35644 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759286AbYGPIYV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:24:21 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/tcp.h |    2 +-
 net/ipv4/tcp.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8a2cd07..92d8769 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -268,7 +268,7 @@ extern struct proto tcp_prot;
 DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 #define TCP_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(tcp_statistics, field); } while (0)
 #define TCP_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(tcp_statistics, field); } while (0)
-#define TCP_DEC_STATS(field)		SNMP_DEC_STATS(tcp_statistics, field)
+#define TCP_DEC_STATS(net, field)	do { (void)net; SNMP_DEC_STATS(tcp_statistics, field); } while (0)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9caaf83..315b82e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1682,7 +1682,7 @@ void tcp_set_state(struct sock *sk, int state)
 		/* fall through */
 	default:
 		if (oldstate==TCP_ESTABLISHED)
-			TCP_DEC_STATS(TCP_MIB_CURRESTAB);
+			TCP_DEC_STATS(sock_net(sk), TCP_MIB_CURRESTAB);
 	}
 
 	/* Change state AFTER socket is unhashed to avoid closed
-- 
1.5.5.1

