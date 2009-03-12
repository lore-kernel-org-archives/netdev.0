From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [IPROUTE2][PATCH 1/2] Add Monitor Support For Neigh Table
Date: Thu, 12 Mar 2009 13:42:07 +0530
Message-ID: <20090312134207.783f00d4.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:43140 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbZCLIML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 04:12:11 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2C8Bw3k007905
	for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 19:11:58 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C8CNu9405946
	for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 19:12:25 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2C8C5et017439
	for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 19:12:05 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds exclusive support to enable monitoring
neighbour table entries in ip command.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 ip/ipmonitor.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index df0fd91..a74730e 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -102,6 +102,7 @@ int do_ipmonitor(int argc, char **argv)
 	int laddr=0;
 	int lroute=0;
 	int lprefix=0;
+	int lneigh=0;
 
 	rtnl_close(&rth);
 	ipaddr_reset_filter(1);
@@ -124,6 +125,9 @@ int do_ipmonitor(int argc, char **argv)
 		} else if (matches(*argv, "prefix") == 0) {
 			lprefix=1;
 			groups = 0;
+		} else if (matches(*argv, "neigh") == 0) {
+			lneigh=1;
+			groups = 0;		
 		} else if (strcmp(*argv, "all") == 0) {
 			groups = ~RTMGRP_TC;
 		} else if (matches(*argv, "help") == 0) {
@@ -153,7 +157,9 @@ int do_ipmonitor(int argc, char **argv)
 		if (!preferred_family || preferred_family == AF_INET6)
 			groups |= nl_mgrp(RTNLGRP_IPV6_PREFIX);
 	}
-
+	if (lneigh) {
+		groups |= nl_mgrp(RTNLGRP_NEIGH);
+	}
 	if (file) {
 		FILE *fp;
 		fp = fopen(file, "r");
-- 
1.5.4.3

