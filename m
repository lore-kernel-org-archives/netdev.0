From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 4/5][SOCK]: Drop inuse pcounter from struct proto
 (v2).
Date: Fri, 28 Mar 2008 15:37:14 +0300
Message-ID: <47ECE67A.2030503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51409 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631AbYC1MhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 08:37:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An uppercut - do not use the pcounter on struct proto.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/sock.h  |    6 ------
 net/dccp/ipv4.c     |    3 ---
 net/dccp/ipv6.c     |    3 ---
 net/ipv4/raw.c      |    3 ---
 net/ipv4/tcp_ipv4.c |    3 ---
 net/ipv4/udp.c      |    3 ---
 net/ipv4/udplite.c  |    3 ---
 net/ipv6/raw.c      |    3 ---
 net/ipv6/tcp_ipv6.c |    3 ---
 net/ipv6/udp.c      |    3 ---
 net/ipv6/udplite.c  |    3 ---
 net/sctp/socket.c   |    5 -----
 12 files changed, 0 insertions(+), 41 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1f42942..2a3344f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -47,7 +47,6 @@
 #include <linux/module.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
-#include <linux/pcounter.h>
 #include <linux/skbuff.h>	/* struct sk_buff */
 #include <linux/mm.h>
 #include <linux/security.h>
@@ -563,7 +562,6 @@ struct proto {
 	/* Keeping track of sockets in use */
 #ifdef CONFIG_PROC_FS
 	unsigned int		inuse_idx;
-	struct pcounter		inuse;
 #endif
 
 	/* Memory pressure */
@@ -636,14 +634,10 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
 
 
 #ifdef CONFIG_PROC_FS
-# define DEFINE_PROTO_INUSE(NAME) DEFINE_PCOUNTER(NAME)
-# define REF_PROTO_INUSE(NAME) PCOUNTER_MEMBER_INITIALIZER(NAME, .inuse)
 /* Called with local bh disabled */
 extern void sock_prot_inuse_add(struct proto *prot, int inc);
 extern int sock_prot_inuse_get(struct proto *proto);
 #else
-# define DEFINE_PROTO_INUSE(NAME)
-# define REF_PROTO_INUSE(NAME)
 static void inline sock_prot_inuse_add(struct proto *prot, int inc)
 {
 }
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 4ca8b0c..7d62f7e 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -915,8 +915,6 @@ static struct timewait_sock_ops dccp_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct inet_timewait_sock),
 };
 
-DEFINE_PROTO_INUSE(dccp_v4)
-
 static struct proto dccp_v4_prot = {
 	.name			= "DCCP",
 	.owner			= THIS_MODULE,
@@ -946,7 +944,6 @@ static struct proto dccp_v4_prot = {
 	.compat_setsockopt	= compat_dccp_setsockopt,
 	.compat_getsockopt	= compat_dccp_getsockopt,
 #endif
-	REF_PROTO_INUSE(dccp_v4)
 };
 
 static struct net_protocol dccp_v4_protocol = {
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 2fec1af..ea3f326 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1100,8 +1100,6 @@ static struct timewait_sock_ops dccp6_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct dccp6_timewait_sock),
 };
 
-DEFINE_PROTO_INUSE(dccp_v6)
-
 static struct proto dccp_v6_prot = {
 	.name		   = "DCCPv6",
 	.owner		   = THIS_MODULE,
@@ -1131,7 +1129,6 @@ static struct proto dccp_v6_prot = {
 	.compat_setsockopt = compat_dccp_setsockopt,
 	.compat_getsockopt = compat_dccp_getsockopt,
 #endif
-	REF_PROTO_INUSE(dccp_v6)
 };
 
 static struct inet6_protocol dccp_v6_protocol = {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index d965f0a..3492050 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -818,8 +818,6 @@ static int raw_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	}
 }
 
-DEFINE_PROTO_INUSE(raw)
-
 struct proto raw_prot = {
 	.name		   = "RAW",
 	.owner		   = THIS_MODULE,
@@ -842,7 +840,6 @@ struct proto raw_prot = {
 	.compat_setsockopt = compat_raw_setsockopt,
 	.compat_getsockopt = compat_raw_getsockopt,
 #endif
-	REF_PROTO_INUSE(raw)
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2a5881c..ef141b8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2451,8 +2451,6 @@ void tcp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */
 
-DEFINE_PROTO_INUSE(tcp)
-
 struct proto tcp_prot = {
 	.name			= "TCP",
 	.owner			= THIS_MODULE,
@@ -2488,7 +2486,6 @@ struct proto tcp_prot = {
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
-	REF_PROTO_INUSE(tcp)
 };
 
 void __init tcp_v4_init(void)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 80007c7..0255f37 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1467,8 +1467,6 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 }
 
-DEFINE_PROTO_INUSE(udp)
-
 struct proto udp_prot = {
 	.name		   = "UDP",
 	.owner		   = THIS_MODULE,
@@ -1496,7 +1494,6 @@ struct proto udp_prot = {
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
-	REF_PROTO_INUSE(udp)
 };
 
 /* ------------------------------------------------------------------------ */
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 53f3ed4..7c1e027 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -34,8 +34,6 @@ static	struct net_protocol udplite_protocol = {
 	.netns_ok	= 1,
 };
 
-DEFINE_PROTO_INUSE(udplite)
-
 struct proto 	udplite_prot = {
 	.name		   = "UDP-Lite",
 	.owner		   = THIS_MODULE,
@@ -60,7 +58,6 @@ struct proto 	udplite_prot = {
 	.compat_setsockopt = compat_udp_setsockopt,
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
-	REF_PROTO_INUSE(udplite)
 };
 
 static struct inet_protosw udplite4_protosw = {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 830da46..c1e495f 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1171,8 +1171,6 @@ static int rawv6_init_sk(struct sock *sk)
 	return(0);
 }
 
-DEFINE_PROTO_INUSE(rawv6)
-
 struct proto rawv6_prot = {
 	.name		   = "RAWv6",
 	.owner		   = THIS_MODULE,
@@ -1196,7 +1194,6 @@ struct proto rawv6_prot = {
 	.compat_setsockopt = compat_rawv6_setsockopt,
 	.compat_getsockopt = compat_rawv6_getsockopt,
 #endif
-	REF_PROTO_INUSE(rawv6)
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 323c7e0..6d851c3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2140,8 +2140,6 @@ void tcp6_proc_exit(struct net *net)
 }
 #endif
 
-DEFINE_PROTO_INUSE(tcpv6)
-
 struct proto tcpv6_prot = {
 	.name			= "TCPv6",
 	.owner			= THIS_MODULE,
@@ -2177,7 +2175,6 @@ struct proto tcpv6_prot = {
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
-	REF_PROTO_INUSE(tcpv6)
 };
 
 static struct inet6_protocol tcpv6_protocol = {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index aacbc82..463ae4d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -999,8 +999,6 @@ void udp6_proc_exit(struct net *net) {
 
 /* ------------------------------------------------------------------------ */
 
-DEFINE_PROTO_INUSE(udpv6)
-
 struct proto udpv6_prot = {
 	.name		   = "UDPv6",
 	.owner		   = THIS_MODULE,
@@ -1027,7 +1025,6 @@ struct proto udpv6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
-	REF_PROTO_INUSE(udpv6)
 };
 
 static struct inet_protosw udpv6_protosw = {
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 706c5c3..c5f5357 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -35,8 +35,6 @@ static struct inet6_protocol udplitev6_protocol = {
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
-DEFINE_PROTO_INUSE(udplitev6)
-
 struct proto udplitev6_prot = {
 	.name		   = "UDPLITEv6",
 	.owner		   = THIS_MODULE,
@@ -60,7 +58,6 @@ struct proto udplitev6_prot = {
 	.compat_setsockopt = compat_udpv6_setsockopt,
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
-	REF_PROTO_INUSE(udplitev6)
 };
 
 static struct inet_protosw udplite6_protosw = {
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 76c7470..00ebd06 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6513,8 +6513,6 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 }
 
 
-DEFINE_PROTO_INUSE(sctp)
-
 /* This proto struct describes the ULP interface for SCTP.  */
 struct proto sctp_prot = {
 	.name        =	"SCTP",
@@ -6544,11 +6542,9 @@ struct proto sctp_prot = {
 	.enter_memory_pressure = sctp_enter_memory_pressure,
 	.memory_allocated = &sctp_memory_allocated,
 	.sockets_allocated = &sctp_sockets_allocated,
-	REF_PROTO_INUSE(sctp)
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-DEFINE_PROTO_INUSE(sctpv6)
 
 struct proto sctpv6_prot = {
 	.name		= "SCTPv6",
@@ -6578,6 +6574,5 @@ struct proto sctpv6_prot = {
 	.enter_memory_pressure = sctp_enter_memory_pressure,
 	.memory_allocated = &sctp_memory_allocated,
 	.sockets_allocated = &sctp_sockets_allocated,
-	REF_PROTO_INUSE(sctpv6)
 };
 #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
-- 
1.5.3.4


