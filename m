From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/7] sysctl:  remove broken netfilter binary sysctls
Date: Fri, 10 Aug 2007 15:06:25 -0600
Message-ID: <m1d4xvw14e.fsf_-_@ebiederm.dsl.xmission.com>
References: <20070809224254.11f42716.akpm@linux-foundation.org>
	<46BC8F71.3070006@googlemail.com> <46BC944F.9020801@googlemail.com>
	<m1fy2rxpje.fsf@ebiederm.dsl.xmission.com>
	<20070810124156.2de9710e.akpm@linux-foundation.org>
	<m1ps1vw1ey.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lkcjw1cc.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcn7w18w.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel C <nix.or.die@googlemail.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, <netdev@vger.kernel.org>,
	coreteam@netfilter.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:57453 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758739AbXHJVGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:06:46 -0400
In-Reply-To: <m1hcn7w18w.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Fri, 10 Aug 2007 15:03:43 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


No one has bothered to set strategy routine for the
the netfilter sysctls that return jiffies to be sysctl_jiffies.

So it appears the sys_sysctl path is unused and untested,
so this patch removes the binary sysctl numbers.

Which fixes the netfilter oops in 2.6.23-rc2-mm2 for me.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 --
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    1 -
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    1 -
 net/netfilter/nf_conntrack_proto_generic.c     |    2 --
 net/netfilter/nf_conntrack_proto_sctp.c        |   14 --------------
 net/netfilter/nf_conntrack_proto_tcp.c         |   18 ------------------
 net/netfilter/nf_conntrack_proto_udp.c         |    4 ----
 7 files changed, 0 insertions(+), 42 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 6593fd2..abdf9d4 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -284,7 +284,6 @@ static int icmp_nfattr_to_tuple(struct nfattr *tb[],
 static struct ctl_table_header *icmp_sysctl_header;
 static struct ctl_table icmp_sysctl_table[] = {
 	{
-		.ctl_name	= NET_NF_CONNTRACK_ICMP_TIMEOUT,
 		.procname	= "nf_conntrack_icmp_timeout",
 		.data		= &nf_ct_icmp_timeout,
 		.maxlen		= sizeof(unsigned int),
@@ -298,7 +297,6 @@ static struct ctl_table icmp_sysctl_table[] = {
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 static struct ctl_table icmp_compat_sysctl_table[] = {
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_ICMP_TIMEOUT,
 		.procname	= "ip_conntrack_icmp_timeout",
 		.data		= &nf_ct_icmp_timeout,
 		.maxlen		= sizeof(unsigned int),
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 3153e15..da4724f 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -305,7 +305,6 @@ static struct nf_hook_ops ipv6_conntrack_ops[] = {
 #ifdef CONFIG_SYSCTL
 static ctl_table nf_ct_ipv6_sysctl_table[] = {
 	{
-		.ctl_name	= NET_NF_CONNTRACK_FRAG6_TIMEOUT,
 		.procname	= "nf_conntrack_frag6_timeout",
 		.data		= &nf_ct_frag6_timeout,
 		.maxlen		= sizeof(unsigned int),
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index ab154fb..85f6ff5 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -263,7 +263,6 @@ static int icmpv6_nfattr_to_tuple(struct nfattr *tb[],
 static struct ctl_table_header *icmpv6_sysctl_header;
 static struct ctl_table icmpv6_sysctl_table[] = {
 	{
-		.ctl_name	= NET_NF_CONNTRACK_ICMPV6_TIMEOUT,
 		.procname	= "nf_conntrack_icmpv6_timeout",
 		.data		= &nf_ct_icmpv6_timeout,
 		.maxlen		= sizeof(unsigned int),
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index d8b5018..13f8191 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -70,7 +70,6 @@ static int new(struct nf_conn *conntrack, const struct sk_buff *skb,
 static struct ctl_table_header *generic_sysctl_header;
 static struct ctl_table generic_sysctl_table[] = {
 	{
-		.ctl_name	= NET_NF_CONNTRACK_GENERIC_TIMEOUT,
 		.procname	= "nf_conntrack_generic_timeout",
 		.data		= &nf_ct_generic_timeout,
 		.maxlen		= sizeof(unsigned int),
@@ -84,7 +83,6 @@ static struct ctl_table generic_sysctl_table[] = {
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 static struct ctl_table generic_compat_sysctl_table[] = {
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_GENERIC_TIMEOUT,
 		.procname	= "ip_conntrack_generic_timeout",
 		.data		= &nf_ct_generic_timeout,
 		.maxlen		= sizeof(unsigned int),
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 04192ac..cb04675 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -476,7 +476,6 @@ static unsigned int sctp_sysctl_table_users;
 static struct ctl_table_header *sctp_sysctl_header;
 static struct ctl_table sctp_sysctl_table[] = {
 	{
-		.ctl_name	= NET_NF_CONNTRACK_SCTP_TIMEOUT_CLOSED,
 		.procname	= "nf_conntrack_sctp_timeout_closed",
 		.data		= &nf_ct_sctp_timeout_closed,
 		.maxlen		= sizeof(unsigned int),
@@ -484,7 +483,6 @@ static struct ctl_table sctp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_SCTP_TIMEOUT_COOKIE_WAIT,
 		.procname	= "nf_conntrack_sctp_timeout_cookie_wait",
 		.data		= &nf_ct_sctp_timeout_cookie_wait,
 		.maxlen		= sizeof(unsigned int),
@@ -492,7 +490,6 @@ static struct ctl_table sctp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_SCTP_TIMEOUT_COOKIE_ECHOED,
 		.procname	= "nf_conntrack_sctp_timeout_cookie_echoed",
 		.data		= &nf_ct_sctp_timeout_cookie_echoed,
 		.maxlen		= sizeof(unsigned int),
@@ -500,7 +497,6 @@ static struct ctl_table sctp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_SCTP_TIMEOUT_ESTABLISHED,
 		.procname	= "nf_conntrack_sctp_timeout_established",
 		.data		= &nf_ct_sctp_timeout_established,
 		.maxlen		= sizeof(unsigned int),
@@ -508,7 +504,6 @@ static struct ctl_table sctp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_SENT,
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_sent",
 		.data		= &nf_ct_sctp_timeout_shutdown_sent,
 		.maxlen		= sizeof(unsigned int),
@@ -516,7 +511,6 @@ static struct ctl_table sctp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_RECD,
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_recd",
 		.data		= &nf_ct_sctp_timeout_shutdown_recd,
 		.maxlen		= sizeof(unsigned int),
@@ -524,7 +518,6 @@ static struct ctl_table sctp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_ACK_SENT,
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_ack_sent",
 		.data		= &nf_ct_sctp_timeout_shutdown_ack_sent,
 		.maxlen		= sizeof(unsigned int),
@@ -539,7 +532,6 @@ static struct ctl_table sctp_sysctl_table[] = {
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 static struct ctl_table sctp_compat_sysctl_table[] = {
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_CLOSED,
 		.procname	= "ip_conntrack_sctp_timeout_closed",
 		.data		= &nf_ct_sctp_timeout_closed,
 		.maxlen		= sizeof(unsigned int),
@@ -547,7 +539,6 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_COOKIE_WAIT,
 		.procname	= "ip_conntrack_sctp_timeout_cookie_wait",
 		.data		= &nf_ct_sctp_timeout_cookie_wait,
 		.maxlen		= sizeof(unsigned int),
@@ -555,7 +546,6 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_COOKIE_ECHOED,
 		.procname	= "ip_conntrack_sctp_timeout_cookie_echoed",
 		.data		= &nf_ct_sctp_timeout_cookie_echoed,
 		.maxlen		= sizeof(unsigned int),
@@ -563,7 +553,6 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_ESTABLISHED,
 		.procname	= "ip_conntrack_sctp_timeout_established",
 		.data		= &nf_ct_sctp_timeout_established,
 		.maxlen		= sizeof(unsigned int),
@@ -571,7 +560,6 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_SENT,
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_sent",
 		.data		= &nf_ct_sctp_timeout_shutdown_sent,
 		.maxlen		= sizeof(unsigned int),
@@ -579,7 +567,6 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_RECD,
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_recd",
 		.data		= &nf_ct_sctp_timeout_shutdown_recd,
 		.maxlen		= sizeof(unsigned int),
@@ -587,7 +574,6 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_SCTP_TIMEOUT_SHUTDOWN_ACK_SENT,
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_ack_sent",
 		.data		= &nf_ct_sctp_timeout_shutdown_ack_sent,
 		.maxlen		= sizeof(unsigned int),
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index eb3fe74..c9d74a2 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1166,7 +1166,6 @@ static unsigned int tcp_sysctl_table_users;
 static struct ctl_table_header *tcp_sysctl_header;
 static struct ctl_table tcp_sysctl_table[] = {
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_TIMEOUT_SYN_SENT,
 		.procname	= "nf_conntrack_tcp_timeout_syn_sent",
 		.data		= &nf_ct_tcp_timeout_syn_sent,
 		.maxlen		= sizeof(unsigned int),
@@ -1174,7 +1173,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_TIMEOUT_SYN_RECV,
 		.procname	= "nf_conntrack_tcp_timeout_syn_recv",
 		.data		= &nf_ct_tcp_timeout_syn_recv,
 		.maxlen		= sizeof(unsigned int),
@@ -1182,7 +1180,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_TIMEOUT_ESTABLISHED,
 		.procname	= "nf_conntrack_tcp_timeout_established",
 		.data		= &nf_ct_tcp_timeout_established,
 		.maxlen		= sizeof(unsigned int),
@@ -1190,7 +1187,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_TIMEOUT_FIN_WAIT,
 		.procname	= "nf_conntrack_tcp_timeout_fin_wait",
 		.data		= &nf_ct_tcp_timeout_fin_wait,
 		.maxlen		= sizeof(unsigned int),
@@ -1198,7 +1194,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_TIMEOUT_CLOSE_WAIT,
 		.procname	= "nf_conntrack_tcp_timeout_close_wait",
 		.data		= &nf_ct_tcp_timeout_close_wait,
 		.maxlen		= sizeof(unsigned int),
@@ -1206,7 +1201,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_TIMEOUT_LAST_ACK,
 		.procname	= "nf_conntrack_tcp_timeout_last_ack",
 		.data		= &nf_ct_tcp_timeout_last_ack,
 		.maxlen		= sizeof(unsigned int),
@@ -1214,7 +1208,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_TIMEOUT_TIME_WAIT,
 		.procname	= "nf_conntrack_tcp_timeout_time_wait",
 		.data		= &nf_ct_tcp_timeout_time_wait,
 		.maxlen		= sizeof(unsigned int),
@@ -1222,7 +1215,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_TIMEOUT_CLOSE,
 		.procname	= "nf_conntrack_tcp_timeout_close",
 		.data		= &nf_ct_tcp_timeout_close,
 		.maxlen		= sizeof(unsigned int),
@@ -1230,7 +1222,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_TIMEOUT_MAX_RETRANS,
 		.procname	= "nf_conntrack_tcp_timeout_max_retrans",
 		.data		= &nf_ct_tcp_timeout_max_retrans,
 		.maxlen		= sizeof(unsigned int),
@@ -1269,7 +1260,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 static struct ctl_table tcp_compat_sysctl_table[] = {
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_SYN_SENT,
 		.procname	= "ip_conntrack_tcp_timeout_syn_sent",
 		.data		= &nf_ct_tcp_timeout_syn_sent,
 		.maxlen		= sizeof(unsigned int),
@@ -1277,7 +1267,6 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_SYN_RECV,
 		.procname	= "ip_conntrack_tcp_timeout_syn_recv",
 		.data		= &nf_ct_tcp_timeout_syn_recv,
 		.maxlen		= sizeof(unsigned int),
@@ -1285,7 +1274,6 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_ESTABLISHED,
 		.procname	= "ip_conntrack_tcp_timeout_established",
 		.data		= &nf_ct_tcp_timeout_established,
 		.maxlen		= sizeof(unsigned int),
@@ -1293,7 +1281,6 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_FIN_WAIT,
 		.procname	= "ip_conntrack_tcp_timeout_fin_wait",
 		.data		= &nf_ct_tcp_timeout_fin_wait,
 		.maxlen		= sizeof(unsigned int),
@@ -1301,7 +1288,6 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_CLOSE_WAIT,
 		.procname	= "ip_conntrack_tcp_timeout_close_wait",
 		.data		= &nf_ct_tcp_timeout_close_wait,
 		.maxlen		= sizeof(unsigned int),
@@ -1309,7 +1295,6 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_LAST_ACK,
 		.procname	= "ip_conntrack_tcp_timeout_last_ack",
 		.data		= &nf_ct_tcp_timeout_last_ack,
 		.maxlen		= sizeof(unsigned int),
@@ -1317,7 +1302,6 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_TIME_WAIT,
 		.procname	= "ip_conntrack_tcp_timeout_time_wait",
 		.data		= &nf_ct_tcp_timeout_time_wait,
 		.maxlen		= sizeof(unsigned int),
@@ -1325,7 +1309,6 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_CLOSE,
 		.procname	= "ip_conntrack_tcp_timeout_close",
 		.data		= &nf_ct_tcp_timeout_close,
 		.maxlen		= sizeof(unsigned int),
@@ -1333,7 +1316,6 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_MAX_RETRANS,
 		.procname	= "ip_conntrack_tcp_timeout_max_retrans",
 		.data		= &nf_ct_tcp_timeout_max_retrans,
 		.maxlen		= sizeof(unsigned int),
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 2a2fd1a..1e38c90 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -146,7 +146,6 @@ static unsigned int udp_sysctl_table_users;
 static struct ctl_table_header *udp_sysctl_header;
 static struct ctl_table udp_sysctl_table[] = {
 	{
-		.ctl_name	= NET_NF_CONNTRACK_UDP_TIMEOUT,
 		.procname	= "nf_conntrack_udp_timeout",
 		.data		= &nf_ct_udp_timeout,
 		.maxlen		= sizeof(unsigned int),
@@ -154,7 +153,6 @@ static struct ctl_table udp_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_UDP_TIMEOUT_STREAM,
 		.procname	= "nf_conntrack_udp_timeout_stream",
 		.data		= &nf_ct_udp_timeout_stream,
 		.maxlen		= sizeof(unsigned int),
@@ -168,7 +166,6 @@ static struct ctl_table udp_sysctl_table[] = {
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 static struct ctl_table udp_compat_sysctl_table[] = {
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_UDP_TIMEOUT,
 		.procname	= "ip_conntrack_udp_timeout",
 		.data		= &nf_ct_udp_timeout,
 		.maxlen		= sizeof(unsigned int),
@@ -176,7 +173,6 @@ static struct ctl_table udp_compat_sysctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_UDP_TIMEOUT_STREAM,
 		.procname	= "ip_conntrack_udp_timeout_stream",
 		.data		= &nf_ct_udp_timeout_stream,
 		.maxlen		= sizeof(unsigned int),
-- 
1.5.1.1.181.g2de0

