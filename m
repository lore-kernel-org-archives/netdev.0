From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 20/20] mib: add net to NET_ADD_STATS_USER
Date: Wed, 16 Jul 2008 12:38:30 +0400
Message-ID: <487DB386.7070802@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43628 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753749AbYGPIid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:38:33 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Done with NET_XXX_STATS macros :)

To be continued...

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h |    2 +-
 net/ipv4/tcp.c   |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index a8275b1..02924fb 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -165,7 +165,7 @@ DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(net_statistics, field); } while (0)
 #define NET_INC_STATS_USER(net, field) 	do { (void)net; SNMP_INC_STATS_USER(net_statistics, field); } while (0)
 #define NET_ADD_STATS_BH(net, field, adnd) do { (void)net; SNMP_ADD_STATS_BH(net_statistics, field, adnd); } while (0)
-#define NET_ADD_STATS_USER(field, adnd)	SNMP_ADD_STATS_USER(net_statistics, field, adnd)
+#define NET_ADD_STATS_USER(net, field, adnd) do { (void)net; SNMP_ADD_STATS_USER(net_statistics, field, adnd); } while (0)
 
 extern unsigned long snmp_fold_field(void *mib[], int offt);
 extern int snmp_mib_init(void *ptr[2], size_t mibsize);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bbbd2fc..e00ef15 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1475,7 +1475,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			/* __ Restore normal policy in scheduler __ */
 
 			if ((chunk = len - tp->ucopy.len) != 0) {
-				NET_ADD_STATS_USER(LINUX_MIB_TCPDIRECTCOPYFROMBACKLOG, chunk);
+				NET_ADD_STATS_USER(sock_net(sk), LINUX_MIB_TCPDIRECTCOPYFROMBACKLOG, chunk);
 				len -= chunk;
 				copied += chunk;
 			}
@@ -1486,7 +1486,7 @@ do_prequeue:
 				tcp_prequeue_process(sk);
 
 				if ((chunk = len - tp->ucopy.len) != 0) {
-					NET_ADD_STATS_USER(LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE, chunk);
+					NET_ADD_STATS_USER(sock_net(sk), LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE, chunk);
 					len -= chunk;
 					copied += chunk;
 				}
@@ -1601,7 +1601,7 @@ skip_copy:
 			tcp_prequeue_process(sk);
 
 			if (copied > 0 && (chunk = len - tp->ucopy.len) != 0) {
-				NET_ADD_STATS_USER(LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE, chunk);
+				NET_ADD_STATS_USER(sock_net(sk), LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE, chunk);
 				len -= chunk;
 				copied += chunk;
 			}
-- 
1.5.5.1

