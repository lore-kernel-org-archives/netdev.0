From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Fw: why is mode of /proc/sys/net/ipv6/icmp directory only 0500?
Date: Thu, 06 Nov 2003 02:28:48 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031106.022848.02505922.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Thu_Nov__6_02:28:48_2003_499)--"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----Next_Part(Thu_Nov__6_02:28:48_2003_499)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David, please apply this. 
I don't see any reason to keep it 0500.
Thanks.

----Next_Part(Thu_Nov__6_02:28:48_2003_499)--
Content-Type: Message/Rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Return-Path: <shep@ginger.lcs.mit.edu>
Received: from cerberus.hongo.wide.ad.jp (root@cerberus.hongo.wide.ad.jp [203.178.139.93])
	by yue.hongo.wide.ad.jp (8.12.3+3.5Wbeta/8.12.3/Debian-6.6) with ESMTP id hA5HHalg009324
	for <yoshfuji@yue.hongo.wide.ad.jp>; Thu, 6 Nov 2003 02:17:36 +0900
Received: from linux6.nezu.wide.ad.jp (linux6.nezu.wide.ad.jp [203.178.142.218])
	by cerberus.hongo.wide.ad.jp (8.12.3+3.5Wbeta/8.12.3/Debian-6.6) with ESMTP id hA5HHO4x014830
	for <yoshfuji@cerberus.hongo.wide.ad.jp>; Thu, 6 Nov 2003 02:17:24 +0900
Received: from ginger.lcs.mit.edu (ginger.lcs.mit.edu [18.26.0.82])
	by linux6.nezu.wide.ad.jp (8.12.3/8.12.3/Debian-6.6) with ESMTP id hA5HHMF1000551
	for <yoshfuji@linux-ipv6.org>; Thu, 6 Nov 2003 02:17:23 +0900
Received: from ginger.lcs.mit.edu (localhost [127.0.0.1])
	by ginger.lcs.mit.edu (8.12.9/8.12.9) with ESMTP id hA5HHHWB027535
	for <yoshfuji@linux-ipv6.org>; Wed, 5 Nov 2003 12:17:21 -0500
Message-Id: <200311051717.hA5HHHWB027535@ginger.lcs.mit.edu>
From: Tim Shepard <shep@alum.mit.edu>
To: yoshfuji@linux-ipv6.org
Subject: why is mode of /proc/sys/net/ipv6/icmp directory only 0500?
Date: Wed, 05 Nov 2003 12:17:17 -0500
Sender: shep@ginger.lcs.mit.edu
MIME-Version: 1.0



I did a google search to find why the mode of the
/proc/sys/net/ipv6/icmp directory is only 0500 and found that it
originates in a patch of yours:

	http://lwn.net/Articles/13656/

Why not have mode 0555, like this patch below?
If not 0555, then IMHO there needs to be a comment that justifies 0500.

			-Tim Shepard


--- net/ipv6/sysctl_net_ipv6.c.DIST	2003-10-25 14:42:54.000000000 -0400
+++ net/ipv6/sysctl_net_ipv6.c	2003-11-05 12:10:34.000000000 -0500
@@ -22,25 +22,25 @@
 ctl_table ipv6_table[] = {
 	{
 		.ctl_name	= NET_IPV6_ROUTE,
 		.procname	= "route",
 		.maxlen		= 0,
 		.mode		= 0555,
 		.child		= ipv6_route_table
 	},
 	{
 		.ctl_name	= NET_IPV6_ICMP,
 		.procname	= "icmp",
 		.maxlen		= 0,
-		.mode		= 0500,
+		.mode		= 0555,
 		.child		= ipv6_icmp_table
 	},
 	{
 		.ctl_name	= NET_IPV6_BINDV6ONLY,
 		.procname	= "bindv6only",
 		.data		= &sysctl_ipv6_bindv6only,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_HIGH_THRESH,

----Next_Part(Thu_Nov__6_02:28:48_2003_499)----
