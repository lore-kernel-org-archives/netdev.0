From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2] ip-link: cut one level indentation
Date: Fri, 14 Aug 2015 03:13:41 +0000
Message-ID: <1439522021-22613-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9812 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbbHNDK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 23:10:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cut one level indentation to make things easier to read.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/iplink.c | 65 +++++++++++++++++++++++++++++++------------------------------
 1 file changed, 33 insertions(+), 32 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 520f750..504aa74 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -1184,40 +1184,41 @@ static void do_help(int argc, char **argv)
 
 int do_iplink(int argc, char **argv)
 {
-	if (argc > 0) {
-		if (iplink_have_newlink()) {
-			if (matches(*argv, "add") == 0)
-				return iplink_modify(RTM_NEWLINK,
-						     NLM_F_CREATE|NLM_F_EXCL,
-						     argc-1, argv+1);
-			if (matches(*argv, "set") == 0 ||
-			    matches(*argv, "change") == 0)
-				return iplink_modify(RTM_NEWLINK, 0,
-						     argc-1, argv+1);
-			if (matches(*argv, "replace") == 0)
-				return iplink_modify(RTM_NEWLINK,
-						     NLM_F_CREATE|NLM_F_REPLACE,
-						     argc-1, argv+1);
-			if (matches(*argv, "delete") == 0)
-				return iplink_modify(RTM_DELLINK, 0,
-						     argc-1, argv+1);
-		} else {
+	if (argc < 1)
+		return ipaddr_list_link(0, NULL);
+
+	if (iplink_have_newlink()) {
+		if (matches(*argv, "add") == 0)
+			return iplink_modify(RTM_NEWLINK,
+					NLM_F_CREATE|NLM_F_EXCL,
+					argc-1, argv+1);
+		if (matches(*argv, "set") == 0 ||
+				matches(*argv, "change") == 0)
+			return iplink_modify(RTM_NEWLINK, 0,
+					argc-1, argv+1);
+		if (matches(*argv, "replace") == 0)
+			return iplink_modify(RTM_NEWLINK,
+					NLM_F_CREATE|NLM_F_REPLACE,
+					argc-1, argv+1);
+		if (matches(*argv, "delete") == 0)
+			return iplink_modify(RTM_DELLINK, 0,
+					argc-1, argv+1);
+	} else {
 #if IPLINK_IOCTL_COMPAT
-			if (matches(*argv, "set") == 0)
-				return do_set(argc-1, argv+1);
+		if (matches(*argv, "set") == 0)
+			return do_set(argc-1, argv+1);
 #endif
-		}
-		if (matches(*argv, "show") == 0 ||
-		    matches(*argv, "lst") == 0 ||
-		    matches(*argv, "list") == 0)
-			return ipaddr_list_link(argc-1, argv+1);
-		if (matches(*argv, "help") == 0) {
-			do_help(argc-1, argv+1);
-			return 0;
-		}
-	} else
-		return ipaddr_list_link(0, NULL);
+	}
+	if (matches(*argv, "show") == 0 ||
+			matches(*argv, "lst") == 0 ||
+			matches(*argv, "list") == 0)
+		return ipaddr_list_link(argc-1, argv+1);
+	if (matches(*argv, "help") == 0) {
+		do_help(argc-1, argv+1);
+		return 0;
+	}
 
-	fprintf(stderr, "Command \"%s\" is unknown, try \"ip link help\".\n", *argv);
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip link help\".\n",
+			*argv);
 	exit(-1);
 }
-- 
1.8.3.1
