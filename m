From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE 08/08]: Increase internal clock resolution to nsec
Date: Sun,  4 Mar 2007 20:15:04 +0100 (MET)
Message-ID: <20070304191413.22838.98460.sendpatchset@localhost.localdomain>
References: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61736 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbXCDTPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:15:05 -0500
In-Reply-To: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Increase internal clock resolution to nsec

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8a76c51f61dd3881bba35f8c73aaa92eabaf50da
tree d4b252b801a14ee19ed77d4a06daaacd8c17b495
parent 0e0db5d408bdac33eadd9d947c0e6904df26ab8f
author Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:50 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:50 +0100

 tc/tc_core.h |    2 +-
 tc/tc_util.c |    7 ++++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/tc/tc_core.h b/tc/tc_core.h
index a139da6..28bf97a 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -4,7 +4,7 @@ #define _TC_CORE_H_ 1
 #include <asm/types.h>
 #include <linux/pkt_sched.h>
 
-#define TIME_UNITS_PER_SEC	1000000
+#define TIME_UNITS_PER_SEC	1000000000
 
 int  tc_core_time2big(long time);
 long tc_core_time2tick(long time);
diff --git a/tc/tc_util.c b/tc/tc_util.c
index a7e4257..a07c6aa 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -228,6 +228,9 @@ int get_time(unsigned *time, const char 
 		else if (strcasecmp(p, "us") == 0 || strcasecmp(p, "usec")==0 ||
 			 strcasecmp(p, "usecs") == 0)
 			t *= TIME_UNITS_PER_SEC/1000000;
+		else if (strcasecmp(p, "ns") == 0 || strcasecmp(p, "nsec")==0 ||
+			 strcasecmp(p, "nsecs") == 0)
+			t *= TIME_UNITS_PER_SEC/1000000000;
 		else
 			return -1;
 	}
@@ -245,8 +248,10 @@ void print_time(char *buf, int len, __u3
 		snprintf(buf, len, "%.1fs", tmp/TIME_UNITS_PER_SEC);
 	else if (tmp >= TIME_UNITS_PER_SEC/1000)
 		snprintf(buf, len, "%.1fms", tmp/(TIME_UNITS_PER_SEC/1000));
+	else if (tmp >= TIME_UNITS_PER_SEC/1000000)
+		snprintf(buf, len, "%.1fus", tmp/(TIME_UNITS_PER_SEC/1000000));
 	else
-		snprintf(buf, len, "%uus", time);
+		snprintf(buf, len, "%uns", time);
 }
 
 char * sprint_time(__u32 time, char *buf)
