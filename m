From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [NET] missing sysctl strategy in net/{core,ipv6,appletalk}
Date: Fri, 26 Dec 2003 02:23:35 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031226.022335.34767838.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

added missing strategy handers.

Thanks.

===== net/core/neighbour.c 1.20 vs edited =====
--- 1.20/net/core/neighbour.c	Tue Oct 21 14:59:11 2003
+++ edited/net/core/neighbour.c	Fri Dec 26 02:00:09 2003
@@ -1518,6 +1518,7 @@
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= &proc_dointvec_jiffies,
+			.strategy	= &sysctl_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_DELAY_PROBE_TIME,
@@ -1525,6 +1526,7 @@
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= &proc_dointvec_jiffies,
+			.strategy	= &sysctl_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_GC_STALE_TIME,
@@ -1532,6 +1534,7 @@
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= &proc_dointvec_jiffies,
+			.strategy	= &sysctl_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_UNRES_QLEN,
@@ -1574,6 +1577,7 @@
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= &proc_dointvec_jiffies,
+			.strategy	= &sysctl_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_GC_THRESH1,
===== net/core/sysctl_net_core.c 1.8 vs edited =====
--- 1.8/net/core/sysctl_net_core.c	Thu Oct 30 05:19:30 2003
+++ edited/net/core/sysctl_net_core.c	Fri Dec 26 02:07:52 2003
@@ -146,7 +146,8 @@
 		.data		= &net_msg_cost,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies
+		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= &sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_CORE_MSG_BURST,
@@ -154,7 +155,8 @@
 		.data		= &net_msg_burst,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies
+		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= &sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_CORE_OPTMEM_MAX,
===== net/ipv6/addrconf.c 1.77 vs edited =====
--- 1.77/net/ipv6/addrconf.c	Wed Nov 26 10:06:32 2003
+++ edited/net/ipv6/addrconf.c	Fri Dec 26 01:57:17 2003
@@ -2946,6 +2946,7 @@
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
          		.proc_handler	=	&proc_dointvec_jiffies,
+			.strategy	=	&sysctl_jiffies,
 		},
 		{
 			.ctl_name	=	NET_IPV6_RTR_SOLICIT_DELAY,
@@ -2954,6 +2955,7 @@
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
          		.proc_handler	=	&proc_dointvec_jiffies,
+			.strategy	=	&sysctl_jiffies,
 		},
 #ifdef CONFIG_IPV6_PRIVACY
 		{
===== net/appletalk/sysctl_net_atalk.c 1.4 vs edited =====
--- 1.4/net/appletalk/sysctl_net_atalk.c	Tue Oct  8 12:05:42 2002
+++ edited/net/appletalk/sysctl_net_atalk.c	Fri Dec 26 02:11:18 2003
@@ -23,6 +23,7 @@
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= &sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_ATALK_AARP_TICK_TIME,
@@ -31,6 +32,7 @@
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= &sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_ATALK_AARP_RETRANSMIT_LIMIT,
@@ -47,6 +49,7 @@
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= &sysctl_jiffies,
 	},
 	{ 0 },
 };


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
