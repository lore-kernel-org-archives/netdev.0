From: Sorin Dumitru <sorin@returnze.ro>
Subject: [PATCH net-next] net: limit tcp/udp rmem/wmem to SOCK_{RCV,SND}BUF_MIN
Date: Wed, 27 May 2015 22:16:49 +0300
Message-ID: <1432754209-21397-1-git-send-email-sorin@returnze.ro>
Cc: davem@davemloft.net, Sorin Dumitru <sorin@returnze.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:38842 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646AbbE0TQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 15:16:58 -0400
Received: by wizo1 with SMTP id o1so34681431wiz.1
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 12:16:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is similar to b1cb59cf2efe(net: sysctl_net_core: check SNDBUF
and RCVBUF for min length). I don't think too small values can cause
crashes in the case of udp and tcp, but I've seen this set to too
small values which triggered awful performance. It also makes the
setting consistent across all the wmem/rmem sysctls.

Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>
---
 net/ipv4/sysctl_net_ipv4.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e648927..4f36afd 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -41,6 +41,8 @@ static int tcp_syn_retries_min = 1;
 static int tcp_syn_retries_max = MAX_TCP_SYNCNT;
 static int ip_ping_group_range_min[] = { 0, 0 };
 static int ip_ping_group_range_max[] = { GID_T_MAX, GID_T_MAX };
+static int min_sndbuf = SOCK_MIN_SNDBUF;
+static int min_rcvbuf = SOCK_MIN_RCVBUF;
 
 /* Update system visible IP port range */
 static void set_local_port_range(struct net *net, int range[2])
@@ -522,7 +524,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(sysctl_tcp_wmem),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &one,
+		.extra1		= &min_sndbuf,
 	},
 	{
 		.procname	= "tcp_notsent_lowat",
@@ -537,7 +539,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(sysctl_tcp_rmem),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &one,
+		.extra1		= &min_rcvbuf,
 	},
 	{
 		.procname	= "tcp_app_win",
@@ -750,7 +752,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(sysctl_udp_rmem_min),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &one
+		.extra1		= &min_rcvbuf,
 	},
 	{
 		.procname	= "udp_wmem_min",
@@ -758,7 +760,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(sysctl_udp_wmem_min),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &one
+		.extra1		= &min_sndbuf,
 	},
 	{ }
 };
-- 
2.4.1
