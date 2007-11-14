From: Simon Horman <horms@verge.net.au>
Subject: [patch 3/3] IPVS: Move remaining sysctl handlers over to CTL_UNNUMBERED
Date: Wed, 14 Nov 2007 10:06:18 -0800
Message-ID: <20071114180824.652798827@natsuko.shinjuku.tokyo.vergenet.net>
References: <20071114180615.251592665@natsuko.shinjuku.tokyo.vergenet.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:36768 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757080AbXKNSKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 13:10:20 -0500
Content-Disposition: inline; filename=ipvs-ctl_unnumbered.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch the remaining IPVS sysctl entries over to to use CTL_UNNUMBERED,
I stronly doubt that anyone is using the sys_sysctl interface to
these variables.

Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

---
 include/net/ip_vs.h         |   28 ----------------------------
 kernel/sysctl_check.c       |   25 -------------------------
 net/ipv4/ipvs/ip_vs_ctl.c   |   20 --------------------
 net/ipv4/ipvs/ip_vs_lblc.c  |    1 -
 net/ipv4/ipvs/ip_vs_lblcr.c |    1 -
 5 files changed, 75 deletions(-)

This alters some commented-out entries. I'd like to deal with
replacing/removing them separately.

Index: net-2.6/include/net/ip_vs.h
===================================================================
--- net-2.6.orig/include/net/ip_vs.h	2007-11-14 09:48:12.000000000 -0800
+++ net-2.6/include/net/ip_vs.h	2007-11-14 09:48:44.000000000 -0800
@@ -328,34 +328,6 @@ extern int ip_vs_get_debug_level(void);
 #define FTPDATA  __constant_htons(20)
 
 /*
- *      IPVS sysctl variables under the /proc/sys/net/ipv4/vs/
- */
-#define NET_IPV4_VS              21
-
-enum {
-	NET_IPV4_VS_DEBUG_LEVEL=1,
-	NET_IPV4_VS_AMEMTHRESH=2,
-	NET_IPV4_VS_AMDROPRATE=3,
-	NET_IPV4_VS_TO_ES=7,
-	NET_IPV4_VS_TO_SS=8,
-	NET_IPV4_VS_TO_SR=9,
-	NET_IPV4_VS_TO_FW=10,
-	NET_IPV4_VS_TO_TW=11,
-	NET_IPV4_VS_TO_CL=12,
-	NET_IPV4_VS_TO_CW=13,
-	NET_IPV4_VS_TO_LA=14,
-	NET_IPV4_VS_TO_LI=15,
-	NET_IPV4_VS_TO_SA=16,
-	NET_IPV4_VS_TO_UDP=17,
-	NET_IPV4_VS_TO_ICMP=18,
-	NET_IPV4_VS_CACHE_BYPASS=22,
-	NET_IPV4_VS_EXPIRE_NODEST_CONN=23,
-	NET_IPV4_VS_NAT_ICMP_SEND=25,
-	NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE=26,
-	NET_IPV4_VS_LAST
-};
-
-/*
  *      TCP State Values
  */
 enum {
Index: net-2.6/kernel/sysctl_check.c
===================================================================
--- net-2.6.orig/kernel/sysctl_check.c	2007-11-14 09:48:51.000000000 -0800
+++ net-2.6/kernel/sysctl_check.c	2007-11-14 09:50:57.000000000 -0800
@@ -237,30 +237,6 @@ static struct trans_ctl_table trans_net_
 	{}
 };
 
-
-static struct trans_ctl_table trans_net_ipv4_vs_table[] = {
-	{ NET_IPV4_VS_AMEMTHRESH,	"amemthresh" },
-	{ NET_IPV4_VS_DEBUG_LEVEL,	"debug_level" },
-	{ NET_IPV4_VS_AMDROPRATE,	"am_droprate" },
-	{ NET_IPV4_VS_TO_ES,		"timeout_established" },
-	{ NET_IPV4_VS_TO_SS,		"timeout_synsent" },
-	{ NET_IPV4_VS_TO_SR,		"timeout_synrecv" },
-	{ NET_IPV4_VS_TO_FW,		"timeout_finwait" },
-	{ NET_IPV4_VS_TO_TW,		"timeout_timewait" },
-	{ NET_IPV4_VS_TO_CL,		"timeout_close" },
-	{ NET_IPV4_VS_TO_CW,		"timeout_closewait" },
-	{ NET_IPV4_VS_TO_LA,		"timeout_lastack" },
-	{ NET_IPV4_VS_TO_LI,		"timeout_listen" },
-	{ NET_IPV4_VS_TO_SA,		"timeout_synack" },
-	{ NET_IPV4_VS_TO_UDP,		"timeout_udp" },
-	{ NET_IPV4_VS_TO_ICMP,		"timeout_icmp" },
-	{ NET_IPV4_VS_CACHE_BYPASS,	"cache_bypass" },
-	{ NET_IPV4_VS_EXPIRE_NODEST_CONN,	"expire_nodest_conn" },
-	{ NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE,	"expire_quiescent_template" },
-	{ NET_IPV4_VS_NAT_ICMP_SEND,	"nat_icmp_send" },
-	{}
-};
-
 static struct trans_ctl_table trans_net_neigh_vars_table[] = {
 	{ NET_NEIGH_MCAST_SOLICIT,	"mcast_solicit" },
 	{ NET_NEIGH_UCAST_SOLICIT,	"ucast_solicit" },
@@ -335,7 +311,6 @@ static struct trans_ctl_table trans_net_
 	{ NET_IPV4_ROUTE,		"route",	trans_net_ipv4_route_table },
 	/* NET_IPV4_FIB_HASH unused */
 	{ NET_IPV4_NETFILTER,		"netfilter",	trans_net_ipv4_netfilter_table },
-	{ NET_IPV4_VS,			"vs",		trans_net_ipv4_vs_table },
 
 	{ NET_IPV4_TCP_TIMESTAMPS,		"tcp_timestamps" },
 	{ NET_IPV4_TCP_WINDOW_SCALING,		"tcp_window_scaling" },
Index: net-2.6/net/ipv4/ipvs/ip_vs_ctl.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c	2007-11-14 09:52:07.000000000 -0800
+++ net-2.6/net/ipv4/ipvs/ip_vs_ctl.c	2007-11-14 09:52:50.000000000 -0800
@@ -1425,7 +1425,6 @@ proc_do_sync_threshold(ctl_table *table,
 
 static struct ctl_table vs_vars[] = {
 	{
-		.ctl_name	= NET_IPV4_VS_AMEMTHRESH,
 		.procname	= "amemthresh",
 		.data		= &sysctl_ip_vs_amemthresh,
 		.maxlen		= sizeof(int),
@@ -1434,7 +1433,6 @@ static struct ctl_table vs_vars[] = {
 	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
-		.ctl_name	= NET_IPV4_VS_DEBUG_LEVEL,
 		.procname	= "debug_level",
 		.data		= &sysctl_ip_vs_debug_level,
 		.maxlen		= sizeof(int),
@@ -1443,7 +1441,6 @@ static struct ctl_table vs_vars[] = {
 	},
 #endif
 	{
-		.ctl_name	= NET_IPV4_VS_AMDROPRATE,
 		.procname	= "am_droprate",
 		.data		= &sysctl_ip_vs_am_droprate,
 		.maxlen		= sizeof(int),
@@ -1473,7 +1470,6 @@ static struct ctl_table vs_vars[] = {
 	},
 #if 0
 	{
-		.ctl_name	= NET_IPV4_VS_TO_ES,
 		.procname	= "timeout_established",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ESTABLISHED],
 		.maxlen		= sizeof(int),
@@ -1481,7 +1477,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_SS,
 		.procname	= "timeout_synsent",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_SENT],
 		.maxlen		= sizeof(int),
@@ -1489,7 +1484,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_SR,
 		.procname	= "timeout_synrecv",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_RECV],
 		.maxlen		= sizeof(int),
@@ -1497,7 +1491,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_FW,
 		.procname	= "timeout_finwait",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_FIN_WAIT],
 		.maxlen		= sizeof(int),
@@ -1505,7 +1498,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_TW,
 		.procname	= "timeout_timewait",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_TIME_WAIT],
 		.maxlen		= sizeof(int),
@@ -1513,7 +1505,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_CL,
 		.procname	= "timeout_close",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE],
 		.maxlen		= sizeof(int),
@@ -1521,7 +1512,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_CW,
 		.procname	= "timeout_closewait",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE_WAIT],
 		.maxlen		= sizeof(int),
@@ -1529,7 +1519,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_LA,
 		.procname	= "timeout_lastack",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LAST_ACK],
 		.maxlen		= sizeof(int),
@@ -1537,7 +1526,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_LI,
 		.procname	= "timeout_listen",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LISTEN],
 		.maxlen		= sizeof(int),
@@ -1545,7 +1533,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_SA,
 		.procname	= "timeout_synack",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYNACK],
 		.maxlen		= sizeof(int),
@@ -1553,7 +1540,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_UDP,
 		.procname	= "timeout_udp",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_UDP],
 		.maxlen		= sizeof(int),
@@ -1561,7 +1547,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_TO_ICMP,
 		.procname	= "timeout_icmp",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ICMP],
 		.maxlen		= sizeof(int),
@@ -1570,7 +1555,6 @@ static struct ctl_table vs_vars[] = {
 	},
 #endif
 	{
-		.ctl_name	= NET_IPV4_VS_CACHE_BYPASS,
 		.procname	= "cache_bypass",
 		.data		= &sysctl_ip_vs_cache_bypass,
 		.maxlen		= sizeof(int),
@@ -1578,7 +1562,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_EXPIRE_NODEST_CONN,
 		.procname	= "expire_nodest_conn",
 		.data		= &sysctl_ip_vs_expire_nodest_conn,
 		.maxlen		= sizeof(int),
@@ -1586,7 +1569,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE,
 		.procname	= "expire_quiescent_template",
 		.data		= &sysctl_ip_vs_expire_quiescent_template,
 		.maxlen		= sizeof(int),
@@ -1601,7 +1583,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_sync_threshold,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_NAT_ICMP_SEND,
 		.procname	= "nat_icmp_send",
 		.data		= &sysctl_ip_vs_nat_icmp_send,
 		.maxlen		= sizeof(int),
@@ -1613,7 +1594,6 @@ static struct ctl_table vs_vars[] = {
 
 static ctl_table vs_table[] = {
 	{
-		.ctl_name	= NET_IPV4_VS,
 		.procname	= "vs",
 		.mode		= 0555,
 		.child		= vs_vars
Index: net-2.6/net/ipv4/ipvs/ip_vs_lblc.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_lblc.c	2007-11-14 09:54:36.000000000 -0800
+++ net-2.6/net/ipv4/ipvs/ip_vs_lblc.c	2007-11-14 09:55:05.000000000 -0800
@@ -125,7 +125,6 @@ static ctl_table vs_vars_table[] = {
 
 static ctl_table vs_table[] = {
 	{
-		.ctl_name	= NET_IPV4_VS,
 		.procname	= "vs",
 		.mode		= 0555,
 		.child		= vs_vars_table
Index: net-2.6/net/ipv4/ipvs/ip_vs_lblcr.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_lblcr.c	2007-11-14 09:55:11.000000000 -0800
+++ net-2.6/net/ipv4/ipvs/ip_vs_lblcr.c	2007-11-14 09:55:24.000000000 -0800
@@ -313,7 +313,6 @@ static ctl_table vs_vars_table[] = {
 
 static ctl_table vs_table[] = {
 	{
-		.ctl_name	= NET_IPV4_VS,
 		.procname	= "vs",
 		.mode		= 0555,
 		.child		= vs_vars_table

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

