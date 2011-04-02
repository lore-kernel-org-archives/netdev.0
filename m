From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 08/24] sysctl: cookie: share ipv4_net_table between nets
Date: Sat,  2 Apr 2011 04:53:22 +0200
Message-ID: <52083d44430cc1c2ce42bd417d28bb4e0f08f9a4.1301711868.git.lucian.grijincu__23154.2613277727$1301713149$gmane$org@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40187 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754312Ab1DBCy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:28 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv4/sysctl_net_ipv4.c |   53 +++++++------------------------------------
 1 files changed, 9 insertions(+), 44 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1766d2e..b7b8dbd 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -635,49 +635,49 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_icmp_echo_ignore_all,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "icmp_echo_ignore_broadcasts",
 		.data		= &init_net.ipv4.sysctl_icmp_echo_ignore_broadcasts,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "icmp_ignore_bogus_error_responses",
 		.data		= &init_net.ipv4.sysctl_icmp_ignore_bogus_error_responses,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "icmp_errors_use_inbound_ifaddr",
 		.data		= &init_net.ipv4.sysctl_icmp_errors_use_inbound_ifaddr,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "icmp_ratelimit",
 		.data		= &init_net.ipv4.sysctl_icmp_ratelimit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_ms_jiffies,
+		.proc_handler	= netns_proc_dointvec_ms_jiffies,
 	},
 	{
 		.procname	= "icmp_ratemask",
 		.data		= &init_net.ipv4.sysctl_icmp_ratemask,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{
 		.procname	= "rt_cache_rebuild_count",
 		.data		= &init_net.ipv4.sysctl_rt_cache_rebuild_count,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= netns_proc_dointvec,
 	},
 	{ }
 };
@@ -691,53 +691,18 @@ EXPORT_SYMBOL_GPL(net_ipv4_ctl_path);
 
 static __net_init int ipv4_sysctl_init_net(struct net *net)
 {
-	struct ctl_table *table;
-
-	table = ipv4_net_table;
-	if (!net_eq(net, &init_net)) {
-		table = kmemdup(table, sizeof(ipv4_net_table), GFP_KERNEL);
-		if (table == NULL)
-			goto err_alloc;
-
-		table[0].data =
-			&net->ipv4.sysctl_icmp_echo_ignore_all;
-		table[1].data =
-			&net->ipv4.sysctl_icmp_echo_ignore_broadcasts;
-		table[2].data =
-			&net->ipv4.sysctl_icmp_ignore_bogus_error_responses;
-		table[3].data =
-			&net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr;
-		table[4].data =
-			&net->ipv4.sysctl_icmp_ratelimit;
-		table[5].data =
-			&net->ipv4.sysctl_icmp_ratemask;
-		table[6].data =
-			&net->ipv4.sysctl_rt_cache_rebuild_count;
-	}
-
 	net->ipv4.sysctl_rt_cache_rebuild_count = 4;
 
 	net->ipv4.ipv4_hdr = register_net_sysctl_table(net,
-			net_ipv4_ctl_path, table);
+			net_ipv4_ctl_path, ipv4_net_table);
 	if (net->ipv4.ipv4_hdr == NULL)
-		goto err_reg;
-
+		return -ENOMEM;
 	return 0;
-
-err_reg:
-	if (!net_eq(net, &init_net))
-		kfree(table);
-err_alloc:
-	return -ENOMEM;
 }
 
 static __net_exit void ipv4_sysctl_exit_net(struct net *net)
 {
-	struct ctl_table *table;
-
-	table = net->ipv4.ipv4_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->ipv4.ipv4_hdr);
-	kfree(table);
 }
 
 static __net_initdata struct pernet_operations ipv4_sysctl_ops = {
-- 
1.7.5.rc0

