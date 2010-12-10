From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] iproute2: initialize the ll_map only once
Date: Fri, 10 Dec 2010 16:59:50 +0200
Message-ID: <1291993190-8838-1-git-send-email-opurdila@ixiacom.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:2409 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754899Ab0LJPAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 10:00:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid initializing the LL map (which involves a costly RTNL dump)
multiple times. This can happen when running in batch mode.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 lib/ll_map.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/ll_map.c b/lib/ll_map.c
index 9831322..9c6144a 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -266,6 +266,11 @@ unsigned ll_name_to_index(const char *name)
 
 int ll_init_map(struct rtnl_handle *rth)
 {
+	static int initialized;
+
+	if (initialized)
+		return 0;
+
 	if (rtnl_wilddump_request(rth, AF_UNSPEC, RTM_GETLINK) < 0) {
 		perror("Cannot send dump request");
 		exit(1);
@@ -275,5 +280,8 @@ int ll_init_map(struct rtnl_handle *rth)
 		fprintf(stderr, "Dump terminated\n");
 		exit(1);
 	}
+
+	initialized = 1;
+
 	return 0;
 }
-- 
1.7.1

