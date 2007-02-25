From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2][ALL] update rest to use nl_mgrp
Date: Sun, 25 Feb 2007 11:55:19 -0500
Message-ID: <1172422519.3942.29.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ltO9+ZNBz1iIVx2kIwB0"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:13001 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbXBYQzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 11:55:23 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1102540wxd
        for <netdev@vger.kernel.org>; Sun, 25 Feb 2007 08:55:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ltO9+ZNBz1iIVx2kIwB0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

cheers,
jamal

--=-ltO9+ZNBz1iIVx2kIwB0
Content-Disposition: attachment; filename=convrestmg
Content-Type: text/plain; name=convrestmg; charset=us-ascii
Content-Transfer-Encoding: 7bit

[ALL] update rest to use nl_mgrp

Signed-off-by: J Hadi Salim <hadi@cyberus.ca>

---
commit 539bc1cc1b002700504ad8cbe82ea451026c5fe4
tree 208bd273db5bf023c33e5256da615a20173c1921
parent 40076f622e0aacb2b792d3ac1b5d12aa97c4da9c
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 25 Feb 2007 11:43:54 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 25 Feb 2007 11:43:54 -0500

 ip/ipmonitor.c  |   12 ++++++------
 ip/rtmon.c      |   10 +++++-----
 tc/tc_monitor.c |    2 +-
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 704ada7..f1a1f27 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -132,22 +132,22 @@ int do_ipmonitor(int argc, char **argv)
 	}
 
 	if (llink)
-		groups |= RTMGRP_LINK;
+		groups |= nl_mgrp(RTNLGRP_LINK);
 	if (laddr) {
 		if (!preferred_family || preferred_family == AF_INET)
-			groups |= RTMGRP_IPV4_IFADDR;
+			groups |= nl_mgrp(RTNLGRP_IPV4_IFADDR);
 		if (!preferred_family || preferred_family == AF_INET6)
-			groups |= RTMGRP_IPV6_IFADDR;
+			groups |= nl_mgrp(RTNLGRP_IPV6_IFADDR);
 	}
 	if (lroute) {
 		if (!preferred_family || preferred_family == AF_INET)
-			groups |= RTMGRP_IPV4_ROUTE;
+			groups |= nl_mgrp(RTNLGRP_IPV4_ROUTE);
 		if (!preferred_family || preferred_family == AF_INET6)
-			groups |= RTMGRP_IPV6_ROUTE;
+			groups |= nl_mgrp(RTNLGRP_IPV6_ROUTE);
 	}
 	if (lprefix) {
 		if (!preferred_family || preferred_family == AF_INET6)
-			groups |= RTMGRP_IPV6_PREFIX;
+			groups |= nl_mgrp(RTNLGRP_IPV6_PREFIX);
 	}
 
 	if (file) {
diff --git a/ip/rtmon.c b/ip/rtmon.c
index 8c464cb..b538a52 100644
--- a/ip/rtmon.c
+++ b/ip/rtmon.c
@@ -134,18 +134,18 @@ main(int argc, char **argv)
 		exit(-1);
 	}
 	if (llink)
-		groups |= RTMGRP_LINK;
+		groups |= nl_mgrp(RTNLGRP_LINK);
 	if (laddr) {
 		if (!family || family == AF_INET)
-			groups |= RTMGRP_IPV4_IFADDR;
+			groups |= nl_mgrp(RTNLGRP_IPV4_IFADDR);
 		if (!family || family == AF_INET6)
-			groups |= RTMGRP_IPV6_IFADDR;
+			groups |= nl_mgrp(RTNLGRP_IPV6_IFADDR);
 	}
 	if (lroute) {
 		if (!family || family == AF_INET)
-			groups |= RTMGRP_IPV4_ROUTE;
+			groups |= nl_mgrp(RTNLGRP_IPV4_ROUTE);
 		if (!family || family == AF_INET6)
-			groups |= RTMGRP_IPV6_ROUTE;
+			groups |= nl_mgrp(RTNLGRP_IPV6_ROUTE);
 	}
 
 	fp = fopen(file, "w");
diff --git a/tc/tc_monitor.c b/tc/tc_monitor.c
index 1af6cf0..bf58744 100644
--- a/tc/tc_monitor.c
+++ b/tc/tc_monitor.c
@@ -68,7 +68,7 @@ int do_tcmonitor(int argc, char **argv)
 {
 	struct rtnl_handle rth;
 	char *file = NULL;
-	unsigned groups = RTMGRP_TC;
+	unsigned groups = nl_mgrp(RTNLGRP_TC);
 
 	while (argc > 0) {
 		if (matches(*argv, "file") == 0) {

--=-ltO9+ZNBz1iIVx2kIwB0--

