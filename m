From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next 1/2] neigh: prevent overflowing params in /proc/sys/net/ipv4/neigh/
Date: Wed, 24 Jul 2013 10:39:06 +0200
Message-ID: <ceef40ec2f64a50afcfc43375a9306ab0661fdf7.1374654531.git.ffusco@redhat.com>
References: <cover.1374654531.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5030 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051Ab3GXIjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 04:39:11 -0400
In-Reply-To: <cover.1374654531.git.ffusco@redhat.com>
In-Reply-To: <cover.1374654531.git.ffusco@redhat.com>
References: <cover.1374654531.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch, the fields app_solicit, gc_thresh1, gc_thresh2,
gc_thresh3, proxy_qlen, ucast_solicit, mcast_solicit could have
assumed negative values when setting large numbers.

Signed-off-by: Francesco Fusco <ffusco@redhat.com>
---
 net/core/neighbour.c | 29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b7de821..9232c68 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2767,6 +2767,7 @@ EXPORT_SYMBOL(neigh_app_ns);
 
 #ifdef CONFIG_SYSCTL
 static int zero;
+static int int_max = INT_MAX;
 static int unres_qlen_max = INT_MAX / SKB_TRUESIZE(ETH_FRAME_LEN);
 
 static int proc_unres_qlen(struct ctl_table *ctl, int write,
@@ -2819,19 +2820,25 @@ static struct neigh_sysctl_table {
 			.procname	= "mcast_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.extra1 	= &zero,
+			.extra2		= &int_max,
+			.proc_handler	= proc_dointvec_minmax,
 		},
 		[NEIGH_VAR_UCAST_PROBE] = {
 			.procname	= "ucast_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.extra1 	= &zero,
+			.extra2		= &int_max,
+			.proc_handler	= proc_dointvec_minmax,
 		},
 		[NEIGH_VAR_APP_PROBE] = {
 			.procname	= "app_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.extra1 	= &zero,
+			.extra2		= &int_max,
+			.proc_handler	= proc_dointvec_minmax,
 		},
 		[NEIGH_VAR_RETRANS_TIME] = {
 			.procname	= "retrans_time",
@@ -2874,7 +2881,9 @@ static struct neigh_sysctl_table {
 			.procname	= "proxy_qlen",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.extra1 	= &zero,
+			.extra2		= &int_max,
+			.proc_handler	= proc_dointvec_minmax,
 		},
 		[NEIGH_VAR_ANYCAST_DELAY] = {
 			.procname	= "anycast_delay",
@@ -2916,19 +2925,25 @@ static struct neigh_sysctl_table {
 			.procname	= "gc_thresh1",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.extra1 	= &zero,
+			.extra2		= &int_max,
+			.proc_handler	= proc_dointvec_minmax,
 		},
 		[NEIGH_VAR_GC_THRESH2] = {
 			.procname	= "gc_thresh2",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.extra1 	= &zero,
+			.extra2		= &int_max,
+			.proc_handler	= proc_dointvec_minmax,
 		},
 		[NEIGH_VAR_GC_THRESH3] = {
 			.procname	= "gc_thresh3",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.extra1 	= &zero,
+			.extra2		= &int_max,
+			.proc_handler	= proc_dointvec_minmax,
 		},
 		{},
 	},
-- 
1.8.3.1
