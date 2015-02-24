From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ip-monitor: allow to monitor ip rules
Date: Tue, 24 Feb 2015 16:15:00 +0100
Message-ID: <1424790900-10257-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38905 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbbBXPPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 10:15:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now done by default or with 'ip monitor rule'.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipmonitor.c        | 14 +++++++++++++-
 man/man8/ip-monitor.8 |  2 +-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 5ec8f4181222..6b5e66534551 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -32,7 +32,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip monitor [ all | LISTofOBJECTS ] [ FILE ]"
 			"[ label ] [dev DEVICE]\n");
 	fprintf(stderr, "LISTofOBJECTS := link | address | route | mroute | prefix |\n");
-	fprintf(stderr, "                 neigh | netconf\n");
+	fprintf(stderr, "                 neigh | netconf | rule\n");
 	fprintf(stderr, "FILE := file FILENAME\n");
 	exit(-1);
 }
@@ -150,6 +150,7 @@ int do_ipmonitor(int argc, char **argv)
 	int lprefix=0;
 	int lneigh=0;
 	int lnetconf=0;
+	int lrule=0;
 	int ifindex=0;
 
 	groups |= nl_mgrp(RTNLGRP_LINK);
@@ -163,6 +164,8 @@ int do_ipmonitor(int argc, char **argv)
 	groups |= nl_mgrp(RTNLGRP_NEIGH);
 	groups |= nl_mgrp(RTNLGRP_IPV4_NETCONF);
 	groups |= nl_mgrp(RTNLGRP_IPV6_NETCONF);
+	groups |= nl_mgrp(RTNLGRP_IPV4_RULE);
+	groups |= nl_mgrp(RTNLGRP_IPV6_RULE);
 
 	rtnl_close(&rth);
 
@@ -193,6 +196,9 @@ int do_ipmonitor(int argc, char **argv)
 		} else if (matches(*argv, "netconf") == 0) {
 			lnetconf = 1;
 			groups = 0;
+		} else if (matches(*argv, "rule") == 0) {
+			lrule = 1;
+			groups = 0;
 		} else if (strcmp(*argv, "all") == 0) {
 			prefix_banner=1;
 		} else if (matches(*argv, "help") == 0) {
@@ -249,6 +255,12 @@ int do_ipmonitor(int argc, char **argv)
 		if (!preferred_family || preferred_family == AF_INET6)
 			groups |= nl_mgrp(RTNLGRP_IPV6_NETCONF);
 	}
+	if (lrule) {
+		if (!preferred_family || preferred_family == AF_INET)
+			groups |= nl_mgrp(RTNLGRP_IPV4_RULE);
+		if (!preferred_family || preferred_family == AF_INET6)
+			groups |= nl_mgrp(RTNLGRP_IPV6_RULE);
+	}
 	if (file) {
 		FILE *fp;
 		fp = fopen(file, "r");
diff --git a/man/man8/ip-monitor.8 b/man/man8/ip-monitor.8
index 544b62567c4d..5ce8dc736efd 100644
--- a/man/man8/ip-monitor.8
+++ b/man/man8/ip-monitor.8
@@ -49,7 +49,7 @@ command is the first in the command line and then the object list follows:
 is the list of object types that we want to monitor.
 It may contain
 .BR link ", " address ", " route ", " mroute ", " prefix ", "
-.BR neigh " and " netconf "."
+.BR neigh ", " netconf " and " rule "."
 If no
 .B file
 argument is given,
-- 
2.2.2
