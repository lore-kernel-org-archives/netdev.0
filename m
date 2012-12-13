From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 2/6] ip: update man pages and usage() for 'ip monitor'
Date: Thu, 13 Dec 2012 14:42:50 +0100
Message-ID: <1355406174-10586-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40569 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754314Ab2LMNpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 08:45:19 -0500
In-Reply-To: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sync with the current code.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipmonitor.c        |  5 ++++-
 man/man8/ip-monitor.8 | 15 +++++++++------
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 09a339c..a9ff1e8 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -29,7 +29,10 @@ int prefix_banner;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip monitor [ all | LISTofOBJECTS ]\n");
+	fprintf(stderr, "Usage: ip monitor [ all | LISTofOBJECTS ] [ FILE ]\n");
+	fprintf(stderr, "LISTofOBJECTS := link | address | route | mroute | prefix |\n");
+	fprintf(stderr, "                 neigh | netconf\n");
+	fprintf(stderr, "FILE := file FILENAME\n");
 	exit(-1);
 }
 
diff --git a/man/man8/ip-monitor.8 b/man/man8/ip-monitor.8
index 351a744..b07cb0e 100644
--- a/man/man8/ip-monitor.8
+++ b/man/man8/ip-monitor.8
@@ -1,4 +1,4 @@
-.TH IP\-MONITOR 8 "20 Dec 2011" "iproute2" "Linux"
+.TH IP\-MONITOR 8 "13 Dec 2012" "iproute2" "Linux"
 .SH "NAME"
 ip-monitor, rtmon \- state monitoring
 .SH "SYNOPSIS"
@@ -6,8 +6,8 @@ ip-monitor, rtmon \- state monitoring
 .ad l
 .in +8
 .ti -8
-.BR "ip monitor" " [ " all " |"
-.IR LISTofOBJECTS " ]"
+.BR "ip " " [ ip-OPTIONS ] " "monitor" " [ " all " |"
+.IR LISTofOBJECTS " ] [ file " FILENAME " ]
 .sp
 
 .SH DESCRIPTION
@@ -20,12 +20,13 @@ Namely, the
 command is the first in the command line and then the object list follows:
 
 .BR "ip monitor" " [ " all " |"
-.IR LISTofOBJECTS " ]"
+.IR LISTofOBJECTS " ] [ file " FILENAME " ]
 
 .I OBJECT-LIST
 is the list of object types that we want to monitor.
 It may contain
-.BR link ", " address " and " route "."
+.BR link ", " address ", " route ", " mroute ", " prefix ", "
+.BR neigh " and " netconf "."
 If no
 .B file
 argument is given,
@@ -34,7 +35,9 @@ opens RTNETLINK, listens on it and dumps state changes in the format
 described in previous sections.
 
 .P
-If a file name is given, it does not listen on RTNETLINK,
+If a
+.I FILENAME
+is given, it does not listen on RTNETLINK,
 but opens the file containing RTNETLINK messages saved in binary format
 and dumps them.  Such a history file can be generated with the
 .B rtmon
-- 
1.8.0.1
