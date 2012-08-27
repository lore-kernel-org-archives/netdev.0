From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH] iproute2: bridge: remove replace and change options
Date: Mon, 27 Aug 2012 10:52:31 -0700
Message-ID: <20120827175231.8706.69184.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37643 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971Ab2H0SIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2012 14:08:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace and change are not supported by bridge netlink so remove it
from bridge tool options.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 bridge/fdb.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index cee0fcd..eaefa81 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -26,7 +26,7 @@ int filter_index;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge fdb { add | del | replace } ADDR dev DEV {self|master}\n");
+	fprintf(stderr, "Usage: bridge fdb { add | del } ADDR dev DEV {self|master}\n");
 	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
 	exit(-1);
 }
@@ -228,11 +228,6 @@ int do_fdb(int argc, char **argv)
 	if (argc > 0) {
 		if (matches(*argv, "add") == 0)
 			return fdb_modify(RTM_NEWNEIGH, NLM_F_CREATE|NLM_F_EXCL, argc-1, argv+1);
-		if (matches(*argv, "change") == 0)
-			return fdb_modify(RTM_NEWNEIGH, NLM_F_REPLACE, argc-1, argv+1);
-
-		if (matches(*argv, "replace") == 0)
-			return fdb_modify(RTM_NEWNEIGH, NLM_F_CREATE|NLM_F_REPLACE, argc-1, argv+1);
 		if (matches(*argv, "delete") == 0)
 			return fdb_modify(RTM_DELNEIGH, 0, argc-1, argv+1);
 		if (matches(*argv, "show") == 0 ||
