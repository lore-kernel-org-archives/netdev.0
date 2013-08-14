From: Martin Schwenke <martin@meltin.net>
Subject: [PATCH] ip monitor: Enable prefix labels when monitoring more than
 1 object
Date: Thu, 15 Aug 2013 07:05:27 +1000
Message-ID: <20130815070527.1df23bea@martins.ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36588 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933137Ab3HNVFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 17:05:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefix labelling is currently only activated when monitoring "all"
objects.  However, the output can still be confusing when monitoring
more than 1 object, so enable prefix labels in this case.

Signed-off-by: Martin Schwenke <martin@meltin.net>
---
 ip/ipmonitor.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 86c473e..62401ea 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -146,6 +146,7 @@ int do_ipmonitor(int argc, char **argv)
 	int lprefix=0;
 	int lneigh=0;
 	int lnetconf=0;
+	int num_objects = 0;
 
 	rtnl_close(&rth);
 	ipaddr_reset_filter(1);
@@ -159,24 +160,31 @@ int do_ipmonitor(int argc, char **argv)
 			file = *argv;
 		} else if (matches(*argv, "link") == 0) {
 			llink=1;
+			num_objects++;
 			groups = 0;
 		} else if (matches(*argv, "address") == 0) {
 			laddr=1;
+			num_objects++;
 			groups = 0;
 		} else if (matches(*argv, "route") == 0) {
 			lroute=1;
+			num_objects++;
 			groups = 0;
 		} else if (matches(*argv, "mroute") == 0) {
 			lmroute=1;
+			num_objects++;
 			groups = 0;
 		} else if (matches(*argv, "prefix") == 0) {
 			lprefix=1;
+			num_objects++;
 			groups = 0;
 		} else if (matches(*argv, "neigh") == 0) {
 			lneigh = 1;
+			num_objects++;
 			groups = 0;
 		} else if (matches(*argv, "netconf") == 0) {
 			lnetconf = 1;
+			num_objects++;
 			groups = 0;
 		} else if (strcmp(*argv, "all") == 0) {
 			groups = ~RTMGRP_TC;
@@ -223,6 +231,9 @@ int do_ipmonitor(int argc, char **argv)
 		if (!preferred_family || preferred_family == AF_INET6)
 			groups |= nl_mgrp(RTNLGRP_IPV6_NETCONF);
 	}
+	if (num_objects > 1) {
+		prefix_banner = 1;
+	}
 	if (file) {
 		FILE *fp;
 		fp = fopen(file, "r");
-- 
1.7.10.4


Can be pulled from git://git.ozlabs.org/~martins/iproute2.git/ctdb.git

I'm not on the list so please CC: me on responses...

peace & happiness,
martin
