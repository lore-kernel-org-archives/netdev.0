From: Vasily Averin <vvs@parallels.com>
Subject: [PATCH] ipv4: NET_IPV4_ROUTE_GC_INTERVAL removal
Date: Fri, 30 Sep 2011 15:11:10 +0400
Message-ID: <1317381070-19564-1-git-send-email-vvs@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, Vasily Averin <vvs@sw.ru>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:56551 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302Ab1I3LL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 07:11:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@sw.ru>

removing obsoleted sysctl, 
ip_rt_gc_interval variable no longer used since 2.6.38

Signed-off-by: Vasily Averin <vvs@sw.ru>
---
 include/linux/sysctl.h |    2 +-
 kernel/sysctl_binary.c |    2 +-
 net/ipv4/route.c       |    8 --------
 3 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 11684d9..9a1ec10 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -435,7 +435,7 @@ enum {
 	NET_IPV4_ROUTE_MAX_SIZE=5,
 	NET_IPV4_ROUTE_GC_MIN_INTERVAL=6,
 	NET_IPV4_ROUTE_GC_TIMEOUT=7,
-	NET_IPV4_ROUTE_GC_INTERVAL=8,
+	NET_IPV4_ROUTE_GC_INTERVAL=8, /* obsolete since 2.6.38 */
 	NET_IPV4_ROUTE_REDIRECT_LOAD=9,
 	NET_IPV4_ROUTE_REDIRECT_NUMBER=10,
 	NET_IPV4_ROUTE_REDIRECT_SILENCE=11,
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index e8bffbe..6318b51 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -214,7 +214,7 @@ static const struct bin_table bin_net_ipv4_route_table[] = {
 	{ CTL_INT,	NET_IPV4_ROUTE_GC_MIN_INTERVAL,		"gc_min_interval" },
 	{ CTL_INT,	NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS,	"gc_min_interval_ms" },
 	{ CTL_INT,	NET_IPV4_ROUTE_GC_TIMEOUT,		"gc_timeout" },
-	{ CTL_INT,	NET_IPV4_ROUTE_GC_INTERVAL,		"gc_interval" },
+	/* NET_IPV4_ROUTE_GC_INTERVAL "gc_interval" no longer used */
 	{ CTL_INT,	NET_IPV4_ROUTE_REDIRECT_LOAD,		"redirect_load" },
 	{ CTL_INT,	NET_IPV4_ROUTE_REDIRECT_NUMBER,		"redirect_number" },
 	{ CTL_INT,	NET_IPV4_ROUTE_REDIRECT_SILENCE,	"redirect_silence" },
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 075212e..f94c20d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -120,7 +120,6 @@
 
 static int ip_rt_max_size;
 static int ip_rt_gc_timeout __read_mostly	= RT_GC_TIMEOUT;
-static int ip_rt_gc_interval __read_mostly	= 60 * HZ;
 static int ip_rt_gc_min_interval __read_mostly	= HZ / 2;
 static int ip_rt_redirect_number __read_mostly	= 9;
 static int ip_rt_redirect_load __read_mostly	= HZ / 50;
@@ -3121,13 +3120,6 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.procname	= "gc_interval",
-		.data		= &ip_rt_gc_interval,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
 		.procname	= "redirect_load",
 		.data		= &ip_rt_redirect_load,
 		.maxlen		= sizeof(int),
-- 
1.7.4.1
