From: roopa@cumulusnetworks.com
Subject: [PATCH iproute2 v2] bridge link: add support to specify master
Date: Thu, 26 Feb 2015 00:12:59 -0800
Message-ID: <1424938379-10716-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, sfeldma@gmail.com
To: netdev@vger.kernel.org, stephen@networkplumber.org,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:42573 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbbBZINF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 03:13:05 -0500
Received: by pdbfp1 with SMTP id fp1so11281426pdb.9
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 00:13:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support to specify 'master' keyword,
to target a bridge link command explicitly to the software
bridge driver.

Adds self/master keywords to usage and man page

v2:
	fix usage to say (self and master) and not (self or master)

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/link.c     |    5 ++++-
 man/man8/bridge.8 |   12 +++++++++++-
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/bridge/link.c b/bridge/link.c
index c8555f8..33dbca4 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -227,6 +227,7 @@ static void usage(void)
 	fprintf(stderr,	"                               [ learning_sync {on | off} ]\n");
 	fprintf(stderr,	"                               [ flood {on | off} ]\n");
 	fprintf(stderr, "                               [ hwmode {vepa | veb} ]\n");
+	fprintf(stderr, "                               [ self ] [ master ]\n");
 	fprintf(stderr, "       bridge link show [dev DEV]\n");
 	exit(-1);
 }
@@ -331,7 +332,9 @@ static int brlink_modify(int argc, char **argv)
 				exit(-1);
 			}
 		} else if (strcmp(*argv, "self") == 0) {
-			flags = BRIDGE_FLAGS_SELF;
+			flags |= BRIDGE_FLAGS_SELF;
+		} else if (strcmp(*argv, "master") == 0) {
+			flags |= BRIDGE_FLAGS_MASTER;
 		} else {
 			usage();
 		}
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index e344db2..19d925f 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -40,7 +40,8 @@ bridge \- show / manipulate bridge addresses and devices
 .BR learning " { " on " | " off " } ] [ "
 .BR learning_sync " { " on " | " off " } ] [ "
 .BR flood " { " on " | " off " } ] [ "
-.BR hwmode " { " vepa " | " veb " } ] "
+.BR hwmode " { " vepa " | " veb " } ] [ "
+.BR self " ]  [ " master " ] "
 
 .ti -8
 .BR "bridge link" " [ " show " ] [ "
@@ -284,6 +285,15 @@ switch.
 .B veb
 - bridging happens in hardware.
 
+.TP
+.BI self
+link setting is configured on specified physical device
+
+.TP
+.BI master
+link setting is configured on the software bridge (default)
+
+
 .SS bridge link show - list bridge port configuration.
 
 This command displays the current bridge port configuration and flags.
-- 
1.7.10.4
