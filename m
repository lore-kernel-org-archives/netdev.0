From: akpm@linux-foundation.org
Subject: [patch 1/1] ipvs: change type of netns_ipvs->sysctl_sync_qlen_max
Date: Mon, 29 Apr 2013 11:55:10 -0700
Message-ID: <20130429185510.DFBB031C266@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	zhangyanfei@cn.fujitsu.com, horms@verge.net.au, ja@ssi.bg
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f74.google.com ([209.85.128.74]:34968 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758358Ab3D2SzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 14:55:12 -0400
Received: by mail-qe0-f74.google.com with SMTP id a11so123526qen.3
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 11:55:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Subject: ipvs: change type of netns_ipvs->sysctl_sync_qlen_max

This member of struct netns_ipvs is calculated from nr_free_buffer_pages
so change its type to unsigned long in case of overflow.  Also, type of
its related proc var sync_qlen_max and the return type of function
sysctl_sync_qlen_max() should be changed to unsigned long, too.

Besides, the type of ipvs_master_sync_state->sync_queue_len should be
changed to unsigned long accordingly.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/net/ip_vs.h            |    8 ++++----
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff -puN include/net/ip_vs.h~ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max include/net/ip_vs.h
--- a/include/net/ip_vs.h~ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max
+++ a/include/net/ip_vs.h
@@ -905,7 +905,7 @@ struct ip_vs_app {
 struct ipvs_master_sync_state {
 	struct list_head	sync_queue;
 	struct ip_vs_sync_buff	*sync_buff;
-	int			sync_queue_len;
+	unsigned long		sync_queue_len;
 	unsigned int		sync_queue_delay;
 	struct task_struct	*master_thread;
 	struct delayed_work	master_wakeup_work;
@@ -998,7 +998,7 @@ struct netns_ipvs {
 	int			sysctl_snat_reroute;
 	int			sysctl_sync_ver;
 	int			sysctl_sync_ports;
-	int			sysctl_sync_qlen_max;
+	unsigned long		sysctl_sync_qlen_max;
 	int			sysctl_sync_sock_size;
 	int			sysctl_cache_bypass;
 	int			sysctl_expire_nodest_conn;
@@ -1085,7 +1085,7 @@ static inline int sysctl_sync_ports(stru
 	return ACCESS_ONCE(ipvs->sysctl_sync_ports);
 }
 
-static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
+static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
 {
 	return ipvs->sysctl_sync_qlen_max;
 }
@@ -1138,7 +1138,7 @@ static inline int sysctl_sync_ports(stru
 	return 1;
 }
 
-static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
+static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
 {
 	return IPVS_SYNC_QLEN_MAX;
 }
diff -puN net/netfilter/ipvs/ip_vs_ctl.c~ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max net/netfilter/ipvs/ip_vs_ctl.c
--- a/net/netfilter/ipvs/ip_vs_ctl.c~ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max
+++ a/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1705,9 +1705,9 @@ static struct ctl_table vs_vars[] = {
 	},
 	{
 		.procname	= "sync_qlen_max",
-		.maxlen		= sizeof(int),
+		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_doulongvec_minmax,
 	},
 	{
 		.procname	= "sync_sock_size",
_
