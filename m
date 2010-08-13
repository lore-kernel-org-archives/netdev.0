From: Min Zhang <mzhang@mvista.com>
Subject: [PATCH] ipv6: remove sysctl jiffies conversion on gc_elasticity and
 min_adv_ms
Date: Fri, 13 Aug 2010 12:50:37 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1008131249060.27872@mvista.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:51978 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab0HMTul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 15:50:41 -0400
Received: by pxi10 with SMTP id 10so923617pxi.19
        for <netdev@vger.kernel.org>; Fri, 13 Aug 2010 12:50:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6: remove sysctl jiffies conversion on gc_elasticity and min_adv_mss

sysctl output ipv6 gc_elasticity and min_adv_mss as values divided by
HZ. However, they are not in unit of jiffies, since ip6_rt_min_advmss
refers to packet size and ip6_rt_fc_elasticity is used as scaler as in
expire>>ip6_rt_gc_elasticity, so replace the jiffies conversion
handler will regular handler for them.

This has impact on scripts that are currently working assuming the
divide by HZ, will yield different results with this patch in place.

Signed-off-by: Min Zhang <mzhang@mvista.com>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 252d761..3b3de49 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2583,7 +2583,7 @@ ctl_table ipv6_route_table_template[] = {
  		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_elasticity,
  		.maxlen		=	sizeof(int),
  		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_jiffies,
+		.proc_handler	=	proc_dointvec,
  	},
  	{
  		.procname	=	"mtu_expires",
@@ -2597,7 +2597,7 @@ ctl_table ipv6_route_table_template[] = {
  		.data		=	&init_net.ipv6.sysctl.ip6_rt_min_advmss,
  		.maxlen		=	sizeof(int),
  		.mode		=	0644,
-		.proc_handler	=	proc_dointvec_jiffies,
+		.proc_handler	=	proc_dointvec,
  	},
  	{
  		.procname	=	"gc_min_interval_ms",
