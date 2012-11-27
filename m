From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 1/2] arping: Fix finding of a default interface when no -I is specified.
Date: Tue, 27 Nov 2012 13:19:34 +0100
Message-ID: <1354018775-4966-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750771Ab2K0MTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 07:19:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, no interface string should be supplied. This ensures that we can
recognize if an interface was specified or omitted. Previously, when -I was not
used, default interface string was compiled-in and the automatic selection
didn't work correctly.

RH-Bugzilla: #879807
Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 Makefile |  4 +---
 arping.c | 11 ++---------
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/Makefile b/Makefile
index ae92f34..b5bf84f 100644
--- a/Makefile
+++ b/Makefile
@@ -24,8 +24,6 @@ USE_SYSFS=no
 USE_IDN=no
 # Do not use getifaddrs
 WITHOUT_IFADDRS=no
-# arping default device
-ARPING_DEFAULT_DEVICE=eth0
 # rdisc server (-r option) support
 ENABLE_RDISC_SERVER=no
 # ping6 source routing (deprecated by RFC5095)
@@ -99,7 +97,7 @@ $(TARGETS): %: %.o
 
 # -------------------------------------
 # arping
-DEF_arping = $(DEF_SYSFS) $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS) -DDEFAULT_DEVICE=\"$(ARPING_DEFAULT_DEVICE)\"
+DEF_arping = $(DEF_SYSFS) $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
 LIB_arping = $(LIB_SYSFS) $(LIB_CAP) $(LIB_IDN)
 
 # clockdiff
diff --git a/arping.c b/arping.c
index f6433c2..ccb68a0 100644
--- a/arping.c
+++ b/arping.c
@@ -55,13 +55,6 @@ struct sysf_devattr_values;
 
 static void usage(void) __attribute__((noreturn));
 
-#ifdef DEFAULT_DEVICE
-# define DEFAULT_DEVICE_STR	DEFAULT_DEVICE
-#else
-# define DEFAULT_DEVICE_STR	"no default"
-# define DEFAULT_DEVICE		NULL
-#endif
-
 struct device {
 	char *name;
 	int ifindex;
@@ -75,7 +68,7 @@ struct device {
 
 int quit_on_reply=0;
 struct device device = {
-	.name = DEFAULT_DEVICE,
+	.name = NULL,
 };
 char *source;
 struct in_addr src, dst;
@@ -128,7 +121,7 @@ void usage(void)
 		"  -V : print version and exit\n"
 		"  -c count : how many packets to send\n"
 		"  -w timeout : how long to wait for a reply\n"
-		"  -I device : which ethernet device to use (" DEFAULT_DEVICE_STR ")\n"
+		"  -I device : which ethernet device to use\n"
 		"  -s source : source ip address\n"
 		"  destination : ask for what ip address\n"
 		);
-- 
1.7.11.7
