From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [IPROUTE2][PATCH 2/2] Enable Type Labels For "ip monitor all"
Date: Thu, 12 Mar 2009 13:42:43 +0530
Message-ID: <20090312134243.1b15fc2c.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:45172 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbZCLIMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 04:12:45 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2C7xXBl023754
	for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 18:59:33 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C8D0Kf381160
	for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 19:13:00 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2C8CgVk029600
	for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 19:12:42 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds prefix lables for "ip monitor all" command to simplfy
understanding of the output.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 ip/ipmonitor.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index a74730e..baf25a8 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -25,6 +25,7 @@
 #include "ip_common.h"
 
 static void usage(void) __attribute__((noreturn));
+int prefix_banner;
 
 static void usage(void)
 {
@@ -42,31 +43,45 @@ int accept_msg(const struct sockaddr_nl *who,
 		print_timestamp(fp);
 
 	if (n->nlmsg_type == RTM_NEWROUTE || n->nlmsg_type == RTM_DELROUTE) {
+		if (prefix_banner)
+			fprintf(fp, "[ROUTE]");
 		print_route(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWLINK || n->nlmsg_type == RTM_DELLINK) {
 		ll_remember_index(who, n, NULL);
+		if (prefix_banner)
+			fprintf(fp, "[LINK]");
 		print_linkinfo(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWADDR || n->nlmsg_type == RTM_DELADDR) {
+		if (prefix_banner)
+			fprintf(fp, "[ADDR]");
 		print_addrinfo(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWADDRLABEL || n->nlmsg_type == RTM_DELADDRLABEL) {
+		if (prefix_banner)
+			fprintf(fp, "[ADDRLABEL]");
 		print_addrlabel(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWNEIGH || n->nlmsg_type == RTM_DELNEIGH) {
+		if (prefix_banner)
+			fprintf(fp, "[NEIGH]");
 		print_neigh(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWPREFIX) {
+		if (prefix_banner)
+			fprintf(fp, "[PREFIX]");
 		print_prefix(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWRULE || n->nlmsg_type == RTM_DELRULE) {
+		if (prefix_banner)
+			fprintf(fp, "[RULE]");
 		print_rule(who, n, arg);
 		return 0;
 	}
@@ -130,6 +145,7 @@ int do_ipmonitor(int argc, char **argv)
 			groups = 0;		
 		} else if (strcmp(*argv, "all") == 0) {
 			groups = ~RTMGRP_TC;
+			prefix_banner=1;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
-- 
1.5.4.3

