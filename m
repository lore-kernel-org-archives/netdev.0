From: Min Zhang <mzhang@mvista.com>
Subject: [PATCH] ipv6: remove sysctl jiffies conversion on gc_elasticity and
 min_adv_ms
Date: Thu, 22 Jul 2010 14:39:14 -0700
Message-ID: <4C48BA82.6020904@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:60425 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967Ab0GVVjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 17:39:20 -0400
Received: by pwi5 with SMTP id 5so3223018pwi.19
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 14:39:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
                .data           =       &init_net.ipv6.sysctl.ip6_rt_gc_elasticity,
                .maxlen         =       sizeof(int),
                .mode           =       0644,
-               .proc_handler   =       proc_dointvec_jiffies,
+               .proc_handler   =       proc_dointvec,
        },
        {
                .procname       =       "mtu_expires",
@@ -2597,7 +2597,7 @@ ctl_table ipv6_route_table_template[] = {
                .data           =       &init_net.ipv6.sysctl.ip6_rt_min_advmss,
                .maxlen         =       sizeof(int),
                .mode           =       0644,
-               .proc_handler   =       proc_dointvec_jiffies,
+               .proc_handler   =       proc_dointvec,
        },
        {
                .procname       =       "gc_min_interval_ms",


