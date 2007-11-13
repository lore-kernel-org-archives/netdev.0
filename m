From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH] IPVS: Fix sysctl warnings about missing strategy
Date: Tue, 13 Nov 2007 11:29:58 +0100
Message-ID: <200711131129.58868.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:65530 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbXKMKaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 05:30:03 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id lADAU0Na433256
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 10:30:00 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lADAU0pC2187294
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 11:30:00 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lADATxEN012411
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 11:30:00 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Running the latest git code I get the following messages during boot:
sysctl table check failed: /net/ipv4/vs/drop_entry .3.5.21.4 Missing strategy
[...]		  
sysctl table check failed: /net/ipv4/vs/drop_packet .3.5.21.5 Missing strategy
[...]
sysctl table check failed: /net/ipv4/vs/secure_tcp .3.5.21.6 Missing strategy
[...]
sysctl table check failed: /net/ipv4/vs/sync_threshold .3.5.21.24 Missing strategy

I removed the binary sysctl handler for those messages and also removed
the definitions in ip_vs.h. The alternative would be to implement a 
proper strategy handler, but syscall sysctl is deprecated.

There are other sysctl definitions that are commented out or work with 
the default sysctl_data strategy. I did not touch these. 

Eric, IPVS team, are you ok with that change?

CC: Eric W. Biederman <ebiederm@xmission.com>
CC: Wensong Zhang <wensong@linux-vs.org>
CC: Simon Horman <horms@verge.net.au>
CC: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>

---
 include/net/ip_vs.h       |    4 ----
 kernel/sysctl_check.c     |    4 ----
 net/ipv4/ipvs/ip_vs_ctl.c |    4 ----
 3 files changed, 12 deletions(-)

Index: linux-2.6/include/net/ip_vs.h
===================================================================
--- linux-2.6.orig/include/net/ip_vs.h
+++ linux-2.6/include/net/ip_vs.h
@@ -336,9 +336,6 @@ enum {
 	NET_IPV4_VS_DEBUG_LEVEL=1,
 	NET_IPV4_VS_AMEMTHRESH=2,
 	NET_IPV4_VS_AMDROPRATE=3,
-	NET_IPV4_VS_DROP_ENTRY=4,
-	NET_IPV4_VS_DROP_PACKET=5,
-	NET_IPV4_VS_SECURE_TCP=6,
 	NET_IPV4_VS_TO_ES=7,
 	NET_IPV4_VS_TO_SS=8,
 	NET_IPV4_VS_TO_SR=9,
@@ -355,7 +352,6 @@ enum {
 	NET_IPV4_VS_LBLCR_EXPIRE=20,
 	NET_IPV4_VS_CACHE_BYPASS=22,
 	NET_IPV4_VS_EXPIRE_NODEST_CONN=23,
-	NET_IPV4_VS_SYNC_THRESHOLD=24,
 	NET_IPV4_VS_NAT_ICMP_SEND=25,
 	NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE=26,
 	NET_IPV4_VS_LAST
Index: linux-2.6/net/ipv4/ipvs/ip_vs_ctl.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c
+++ linux-2.6/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1451,7 +1451,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_DROP_ENTRY,
 		.procname	= "drop_entry",
 		.data		= &sysctl_ip_vs_drop_entry,
 		.maxlen		= sizeof(int),
@@ -1459,7 +1458,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_defense_mode,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_DROP_PACKET,
 		.procname	= "drop_packet",
 		.data		= &sysctl_ip_vs_drop_packet,
 		.maxlen		= sizeof(int),
@@ -1467,7 +1465,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_defense_mode,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_SECURE_TCP,
 		.procname	= "secure_tcp",
 		.data		= &sysctl_ip_vs_secure_tcp,
 		.maxlen		= sizeof(int),
@@ -1597,7 +1594,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_VS_SYNC_THRESHOLD,
 		.procname	= "sync_threshold",
 		.data		= &sysctl_ip_vs_sync_threshold,
 		.maxlen		= sizeof(sysctl_ip_vs_sync_threshold),
Index: linux-2.6/kernel/sysctl_check.c
===================================================================
--- linux-2.6.orig/kernel/sysctl_check.c
+++ linux-2.6/kernel/sysctl_check.c
@@ -242,9 +242,6 @@ static struct trans_ctl_table trans_net_
 	{ NET_IPV4_VS_AMEMTHRESH,	"amemthresh" },
 	{ NET_IPV4_VS_DEBUG_LEVEL,	"debug_level" },
 	{ NET_IPV4_VS_AMDROPRATE,	"am_droprate" },
-	{ NET_IPV4_VS_DROP_ENTRY,	"drop_entry" },
-	{ NET_IPV4_VS_DROP_PACKET,	"drop_packet" },
-	{ NET_IPV4_VS_SECURE_TCP,	"secure_tcp" },
 	{ NET_IPV4_VS_TO_ES,		"timeout_established" },
 	{ NET_IPV4_VS_TO_SS,		"timeout_synsent" },
 	{ NET_IPV4_VS_TO_SR,		"timeout_synrecv" },
@@ -260,7 +257,6 @@ static struct trans_ctl_table trans_net_
 	{ NET_IPV4_VS_CACHE_BYPASS,	"cache_bypass" },
 	{ NET_IPV4_VS_EXPIRE_NODEST_CONN,	"expire_nodest_conn" },
 	{ NET_IPV4_VS_EXPIRE_QUIESCENT_TEMPLATE,	"expire_quiescent_template" },
-	{ NET_IPV4_VS_SYNC_THRESHOLD,		"sync_threshold" },
 	{ NET_IPV4_VS_NAT_ICMP_SEND,	"nat_icmp_send" },
 	{ NET_IPV4_VS_LBLC_EXPIRE,		"lblc_expiration" },
 	{ NET_IPV4_VS_LBLCR_EXPIRE,		"lblcr_expiration" },
