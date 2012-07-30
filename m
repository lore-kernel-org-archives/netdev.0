From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: remove rt_cache_rebuild_count
Date: Mon, 30 Jul 2012 19:14:29 +0200
Message-ID: <1343668469.21269.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57388 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151Ab2G3ROe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 13:14:34 -0400
Received: by bkwj10 with SMTP id j10so2929390bkw.19
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2012 10:14:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After IP route cache removal, rt_cache_rebuild_count is no longer
used.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 Documentation/networking/ip-sysctl.txt |    6 ------
 include/net/netns/ipv4.h               |    2 --
 net/ipv4/sysctl_net_ipv4.c             |   11 -----------
 3 files changed, 19 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 406a522..ca447b3 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -48,12 +48,6 @@ min_adv_mss - INTEGER
 	The advertised MSS depends on the first hop route MTU, but will
 	never be lower than this setting.
 
-rt_cache_rebuild_count - INTEGER
-	The per net-namespace route cache emergency rebuild threshold.
-	Any net-namespace having its route cache rebuilt due to
-	a hash bucket chain being too long more than this many times
-	will have its route caching disabled
-
 IP Fragmentation:
 
 ipfrag_high_thresh - INTEGER
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 0ffb8e3..1474dd6 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -61,8 +61,6 @@ struct netns_ipv4 {
 	int sysctl_icmp_ratelimit;
 	int sysctl_icmp_ratemask;
 	int sysctl_icmp_errors_use_inbound_ifaddr;
-	int sysctl_rt_cache_rebuild_count;
-	int current_rt_cache_rebuild_count;
 
 	unsigned int sysctl_ping_group_range[2];
 	long sysctl_tcp_mem[3];
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 5840c32..4b6487a 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -784,13 +784,6 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "rt_cache_rebuild_count",
-		.data		= &init_net.ipv4.sysctl_rt_cache_rebuild_count,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "ping_group_range",
 		.data		= &init_net.ipv4.sysctl_ping_group_range,
 		.maxlen		= sizeof(init_net.ipv4.sysctl_ping_group_range),
@@ -829,8 +822,6 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 		table[5].data =
 			&net->ipv4.sysctl_icmp_ratemask;
 		table[6].data =
-			&net->ipv4.sysctl_rt_cache_rebuild_count;
-		table[7].data =
 			&net->ipv4.sysctl_ping_group_range;
 
 	}
@@ -842,8 +833,6 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	net->ipv4.sysctl_ping_group_range[0] = 1;
 	net->ipv4.sysctl_ping_group_range[1] = 0;
 
-	net->ipv4.sysctl_rt_cache_rebuild_count = 4;
-
 	tcp_init_mem(net);
 
 	net->ipv4.ipv4_hdr = register_net_sysctl(net, "net/ipv4", table);
