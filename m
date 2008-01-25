From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch net-2.6.25][IPV6][SYSCTL] fix sysctl compilation error
Date: Fri, 25 Jan 2008 14:32:23 +0100
Message-ID: <4799E4E7.5020000@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090604080000040402010805"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:25779 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754599AbYAYNfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 08:35:48 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0PDZemY197918
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 13:35:40 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0PDZe3P2232574
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 13:35:40 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0PDZbJ5030211
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 13:35:37 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090604080000040402010805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------090604080000040402010805
Content-Type: text/x-patch;
 name="fix-sysctl-compilation-error.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-sysctl-compilation-error.patch"

Subject: fix sysctl compilation error
From: Daniel Lezcano <dlezcano@fr.ibm.com>

Move ipv6_icmp_sysctl_init and ipv6_route_sysctl_init into
the right ifdef section otherwise that does not compile when
CONFIG_SYSCTL=yes and CONFIG_PROC_FS=no

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

Index: net-2.6.25-fix/include/net/ipv6.h
===================================================================
--- net-2.6.25-fix.orig/include/net/ipv6.h
+++ net-2.6.25-fix/include/net/ipv6.h
@@ -110,7 +110,6 @@ struct frag_hdr {
 
 /* sysctls */
 extern int sysctl_mld_max_msf;
-
 extern struct ctl_path net_ipv6_ctl_path[];
 
 #define _DEVINC(statname, modifier, idev, field)			\
@@ -586,9 +585,6 @@ extern int ip6_mc_msfget(struct sock *sk
 			 int __user *optlen);
 
 #ifdef CONFIG_PROC_FS
-extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
-extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
-
 extern int  ac6_proc_init(void);
 extern void ac6_proc_exit(void);
 extern int  raw6_proc_init(void);
@@ -621,6 +617,8 @@ static inline int snmp6_unregister_dev(s
 extern ctl_table ipv6_route_table_template[];
 extern ctl_table ipv6_icmp_table_template[];
 
+extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
+extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
 extern int ipv6_sysctl_register(void);
 extern void ipv6_sysctl_unregister(void);
 #endif

--------------090604080000040402010805--
