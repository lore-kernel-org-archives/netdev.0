From: Simon Horman <horms@verge.net.au>
Subject: [patch 2/3] IPVS: Fix sysctl warnings about missing strategy in schedulers
Date: Wed, 14 Nov 2007 10:06:17 -0800
Message-ID: <20071114180823.092364787@natsuko.shinjuku.tokyo.vergenet.net>
References: <20071114180615.251592665@natsuko.shinjuku.tokyo.vergenet.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:36758 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757717AbXKNSKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 13:10:16 -0500
Content-Disposition: inline; filename=fix-sysctl-warnings-about-missing-strategy-lblc-and-lblcr.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sysctl table check failed: /net/ipv4/vs/lblc_expiration .3.5.21.19 Missing strategy
[...]
sysctl table check failed: /net/ipv4/vs/lblcr_expiration .3.5.21.20 Missing strategy

Switch these entried over to use CTL_UNNUMBERED as clearly
the sys_syscal portion wasn't working.

This is along the same lines as Christian Borntraeger's patch that fixes
up entries with no stratergy in net/ipv4/ipvs/ip_vs_ctl.c

Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
 include/net/ip_vs.h         |    2 --
 kernel/sysctl_check.c       |    2 --
 net/ipv4/ipvs/ip_vs_lblc.c  |    1 -
 net/ipv4/ipvs/ip_vs_lblcr.c |    1 -
 4 files changed, 6 deletions(-)
Index: net-2.6/include/net/ip_vs.h
===================================================================
--- net-2.6.orig/include/net/ip_vs.h	2007-11-14 09:37:57.000000000 -0800
+++ net-2.6/include/net/ip_vs.h	2007-11-14 09:38:07.000000000 -0800
@@ -348,8 +348,6 @@ enum {
 	NET_IPV4_VS_TO_SA=16,
 	NET_IPV4_VS_TO_UDP=17,
 	NET_IPV4_VS_TO_ICMP=18,
-	NET_IPV4_VS_LBLC_EXPIRE=19,
-	NET_IPV4_VS_LBLCR_EXPIRE=20,
 	NET_IPV4_VS_CACHE_BYPASS=22,
 	NET_IPV4_VS_EXPIRE_NODEST_CONN=23,
 	NET_IPV4_VS_NAT_ICMP_SEND=25,
Index: net-2.6/kernel/sysctl_check.c
===================================================================
--- net-2.6.orig/kernel/sysctl_check.c	2007-11-14 09:36:10.000000000 -0800
+++ net-2.6/kernel/sysctl_check.c	2007-11-14 09:37:50.000000000 -0800
@@ -258,8 +258,6 @@ static struct trans_ctl_table trans_net_
 	{ NET_IPV4_VS_EXPIRE_NODEST_CONN,	"expire_nodest_conn" },
 	{ NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE,	"expire_quiescent_template" },
 	{ NET_IPV4_VS_NAT_ICMP_SEND,	"nat_icmp_send" },
-	{ NET_IPV4_VS_LBLC_EXPIRE,		"lblc_expiration" },
-	{ NET_IPV4_VS_LBLCR_EXPIRE,		"lblcr_expiration" },
 	{}
 };
 
Index: net-2.6/net/ipv4/ipvs/ip_vs_lblc.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_lblc.c	2007-11-14 09:35:17.000000000 -0800
+++ net-2.6/net/ipv4/ipvs/ip_vs_lblc.c	2007-11-14 09:36:01.000000000 -0800
@@ -114,7 +114,6 @@ struct ip_vs_lblc_table {
 
 static ctl_table vs_vars_table[] = {
 	{
-		.ctl_name	= NET_IPV4_VS_LBLC_EXPIRE,
 		.procname	= "lblc_expiration",
 		.data		= &sysctl_ip_vs_lblc_expiration,
 		.maxlen		= sizeof(int),
Index: net-2.6/net/ipv4/ipvs/ip_vs_lblcr.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_lblcr.c	2007-11-14 09:35:19.000000000 -0800
+++ net-2.6/net/ipv4/ipvs/ip_vs_lblcr.c	2007-11-14 09:35:48.000000000 -0800
@@ -302,7 +302,6 @@ struct ip_vs_lblcr_table {
 
 static ctl_table vs_vars_table[] = {
 	{
-		.ctl_name	= NET_IPV4_VS_LBLCR_EXPIRE,
 		.procname	= "lblcr_expiration",
 		.data		= &sysctl_ip_vs_lblcr_expiration,
 		.maxlen		= sizeof(int),

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

