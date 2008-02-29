From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/12 net-2.6.26] [INET]: Remove struct net_proto_family* from _init calls.
Date: Fri, 29 Feb 2008 16:40:47 +0300
Message-ID: <1204292458-11636-1-git-send-email-den@openvz.org>
References: <1204292360.10368.11.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:54545 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759807AbYB2Nkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 08:40:42 -0500
In-Reply-To: <1204292360.10368.11.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_proto_family* is not used in icmp[v6]_init, ndisc_init, igmp_init
and tcp_v4_init. Remove it.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/linux/icmpv6.h |    2 +-
 include/net/icmp.h     |    2 +-
 include/net/ndisc.h    |    4 ++--
 include/net/tcp.h      |    2 +-
 net/ipv4/af_inet.c     |    4 ++--
 net/ipv4/icmp.c        |    2 +-
 net/ipv4/tcp_ipv4.c    |    2 +-
 net/ipv6/af_inet6.c    |    6 +++---
 net/ipv6/icmp.c        |    2 +-
 net/ipv6/mcast.c       |    2 +-
 net/ipv6/ndisc.c       |    2 +-
 11 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 7c5e981..8f86d6b 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -176,7 +176,7 @@ extern void				icmpv6_send(struct sk_buff *skb,
 						    __u32 info, 
 						    struct net_device *dev);
 
-extern int				icmpv6_init(struct net_proto_family *ops);
+extern int				icmpv6_init(void);
 extern int				icmpv6_err_convert(int type, int code,
 							   int *err);
 extern void				icmpv6_cleanup(void);
diff --git a/include/net/icmp.h b/include/net/icmp.h
index 9f7ef3c..7bf714d 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -48,7 +48,7 @@ struct sk_buff;
 extern void	icmp_send(struct sk_buff *skb_in,  int type, int code, __be32 info);
 extern int	icmp_rcv(struct sk_buff *skb);
 extern int	icmp_ioctl(struct sock *sk, int cmd, unsigned long arg);
-extern void	icmp_init(struct net_proto_family *ops);
+extern void	icmp_init(void);
 extern void	icmp_out_count(unsigned char type);
 
 /* Move into dst.h ? */
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 59b7062..5aedf32 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -77,7 +77,7 @@ struct nd_opt_hdr {
 } __attribute__((__packed__));
 
 
-extern int			ndisc_init(struct net_proto_family *ops);
+extern int			ndisc_init(void);
 
 extern void			ndisc_cleanup(void);
 
@@ -107,7 +107,7 @@ extern int			ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *d
 /*
  *	IGMP
  */
-extern int			igmp6_init(struct net_proto_family *ops);
+extern int			igmp6_init(void);
 
 extern void			igmp6_cleanup(void);
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7de4ea3..ae9774b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1373,7 +1373,7 @@ struct tcp_request_sock_ops {
 #endif
 };
 
-extern void tcp_v4_init(struct net_proto_family *ops);
+extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
 #endif	/* _TCP_H */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c270080..a7a99ac 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1415,7 +1415,7 @@ static int __init inet_init(void)
 
 	ip_init();
 
-	tcp_v4_init(&inet_family_ops);
+	tcp_v4_init();
 
 	/* Setup TCP slab cache for open requests. */
 	tcp_init();
@@ -1430,7 +1430,7 @@ static int __init inet_init(void)
 	 *	Set the ICMP layer up
 	 */
 
-	icmp_init(&inet_family_ops);
+	icmp_init();
 
 	/*
 	 *	Initialise the multicast router
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index a13c074..98372db 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1139,7 +1139,7 @@ static const struct icmp_control icmp_pointers[NR_ICMP_TYPES + 1] = {
 	},
 };
 
-void __init icmp_init(struct net_proto_family *ops)
+void __init icmp_init(void)
 {
 	struct inet_sock *inet;
 	int i;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 00156bf..256032a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2443,7 +2443,7 @@ struct proto tcp_prot = {
 	REF_PROTO_INUSE(tcp)
 };
 
-void __init tcp_v4_init(struct net_proto_family *ops)
+void __init tcp_v4_init(void)
 {
 	if (inet_csk_ctl_sock_create(&tcp_socket, PF_INET, SOCK_RAW,
 				     IPPROTO_TCP) < 0)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index f0aa977..9869f87 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -808,13 +808,13 @@ static int __init inet6_init(void)
 	if (err)
 		goto sysctl_fail;
 #endif
-	err = icmpv6_init(&inet6_family_ops);
+	err = icmpv6_init();
 	if (err)
 		goto icmp_fail;
-	err = ndisc_init(&inet6_family_ops);
+	err = ndisc_init();
 	if (err)
 		goto ndisc_fail;
-	err = igmp6_init(&inet6_family_ops);
+	err = igmp6_init();
 	if (err)
 		goto igmp_fail;
 	err = ipv6_netfilter_init();
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 121d517..b9b13a7 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -780,7 +780,7 @@ drop_no_count:
  */
 static struct lock_class_key icmpv6_socket_sk_dst_lock_key;
 
-int __init icmpv6_init(struct net_proto_family *ops)
+int __init icmpv6_init(void)
 {
 	struct sock *sk;
 	int err, i, j;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index ab228d1..8ce894d 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2597,7 +2597,7 @@ static const struct file_operations igmp6_mcf_seq_fops = {
 };
 #endif
 
-int __init igmp6_init(struct net_proto_family *ops)
+int __init igmp6_init(void)
 {
 	struct ipv6_pinfo *np;
 	struct sock *sk;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0d33a7d..1fc33c8 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1733,7 +1733,7 @@ static int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl, int __user *name,
 
 #endif
 
-int __init ndisc_init(struct net_proto_family *ops)
+int __init ndisc_init(void)
 {
 	struct ipv6_pinfo *np;
 	struct sock *sk;
-- 
1.5.3.rc5

