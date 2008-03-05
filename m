From: therbert@google.com (Tom Herbert)
Subject: RFC [PATCH net-2.6 4/6] net: softRSS sysctls
Date: Wed,  5 Mar 2008 12:51:16 -0800 (PST)
Message-ID: <20080305205116.5FDAB412791@localhost>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:19860 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755103AbYCEUvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 15:51:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds sysctls for enabling/disabling software RSS.

Signed-off-by: Tom Herbert <therbert@google.com>

---

diff -uprN -X /tmp/donts/rss_2 net-2.6/include/linux/sysctl.h net-2.6.patch/include/linux/sysctl.h
--- net-2.6/include/linux/sysctl.h	2008-03-05 09:03:23.482838000 -0800
+++ net-2.6.patch/include/linux/sysctl.h	2008-03-05 09:25:33.573767000 -0800
@@ -285,6 +285,8 @@ enum
 	NET_CORE_AEVENT_ETIME=20,
 	NET_CORE_AEVENT_RSEQTH=21,
 	NET_CORE_WARNINGS=22,
+	NET_CORE_NAPI_RSS=23,
+	NET_CORE_SOFT_RSS=24,
 };
 
 /* /proc/sys/net/ethernet */
diff -uprN -X /tmp/donts/rss_2 net-2.6/net/core/sysctl_net_core.c net-2.6.patch/net/core/sysctl_net_core.c
--- net-2.6/net/core/sysctl_net_core.c	2008-03-05 09:03:28.270548000 -0800
+++ net-2.6.patch/net/core/sysctl_net_core.c	2008-03-05 09:25:33.644759000 -0800
@@ -148,6 +148,26 @@ static struct ctl_table net_core_table[]
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+#ifdef CONFIG_NET_NAPI_RSS
+	{
+		.ctl_name	= NET_CORE_NAPI_RSS,
+		.procname	= "napi_rss",
+		.data		= &sysctl_napi_rss,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+#endif /* CONFIG_NET_NAPI_RSS */
+#ifdef CONFIG_NET_SOFTRSS
+	{
+		.ctl_name	= NET_CORE_SOFT_RSS,
+		.procname	= "soft_rss",
+		.data		= &sysctl_soft_rss,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+#endif /* CONFIG_NET_SOFTRSS */
 	{ .ctl_name = 0 }
 };
 
