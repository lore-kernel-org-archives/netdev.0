From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ipl2tp: Print help even on systems without l2tp support
Date: Wed, 24 Feb 2016 09:12:47 +0100
Message-ID: <1456301567-32474-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50601 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755752AbcBXINA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:13:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipl2tp.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index f050880eef02a..3e3b21ddfb7fe 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -720,6 +720,9 @@ static int do_show(int argc, char **argv)
 
 int do_ipl2tp(int argc, char **argv)
 {
+	if (argc < 1 || !matches(*argv, "help"))
+		usage();
+
 	if (genl_family < 0) {
 		if (rtnl_open_byproto(&genl_rth, 0, NETLINK_GENERIC) < 0) {
 			fprintf(stderr, "Cannot open generic netlink socket\n");
@@ -731,9 +734,6 @@ int do_ipl2tp(int argc, char **argv)
 			exit(1);
 	}
 
-	if (argc < 1)
-		usage();
-
 	if (matches(*argv, "add") == 0)
 		return do_add(argc-1, argv+1);
 	if (matches(*argv, "delete") == 0)
@@ -742,8 +742,6 @@ int do_ipl2tp(int argc, char **argv)
 	    matches(*argv, "lst") == 0 ||
 	    matches(*argv, "list") == 0)
 		return do_show(argc-1, argv+1);
-	if (matches(*argv, "help") == 0)
-		usage();
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip l2tp help\".\n", *argv);
 	exit(-1);
-- 
2.6.4
