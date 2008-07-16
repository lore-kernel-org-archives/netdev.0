From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 8/20] tcp: add net to tcp_mib_init
Date: Wed, 16 Jul 2008 12:19:13 +0400
Message-ID: <487DAF01.6020802@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38542 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754806AbYGPITU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:19:20 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one sets TCP MIBs after zeroing them, and thus requires
the net.

The existing single caller can use init_net (temporarily).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/tcp.h  |    2 +-
 net/ipv4/af_inet.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 048f8de..b9d0ba6 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1024,7 +1024,7 @@ static inline int tcp_paws_check(const struct tcp_options_received *rx_opt, int
 
 #define TCP_CHECK_TIMER(sk) do { } while (0)
 
-static inline void tcp_mib_init(void)
+static inline void tcp_mib_init(struct net *net)
 {
 	/* See RFC 2012 */
 	TCP_ADD_STATS_USER(TCP_MIB_RTOALGORITHM, 1);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index dc41133..95a966d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1363,7 +1363,7 @@ static int __init init_ipv4_mibs(void)
 			  sizeof(struct udp_mib)) < 0)
 		goto err_udplite_mib;
 
-	tcp_mib_init();
+	tcp_mib_init(&init_net);
 
 	return 0;
 
-- 
1.5.5.1

