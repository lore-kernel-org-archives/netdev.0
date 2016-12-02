From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 07/18] ss: Eliminate unix_use_proc()
Date: Fri,  2 Dec 2016 11:39:51 +0100
Message-ID: <20161202104002.17310-8-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45801 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933965AbcLBKk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:40:57 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is used only at a single place anymore, so replace the
call to it by it's content, which makes that specific part of
unix_show() consistent with e.g. tcp_show().

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 0de336200142f..ad38eb97b0055 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2995,11 +2995,6 @@ static bool unix_type_skip(struct sockstat *s, struct filter *f)
 	return false;
 }
 
-static bool unix_use_proc(void)
-{
-	return getenv("PROC_NET_UNIX") || getenv("PROC_ROOT");
-}
-
 static void unix_stats_print(struct sockstat *s, struct filter *f)
 {
 	char port_name[30] = {};
@@ -3123,7 +3118,8 @@ static int unix_show(struct filter *f)
 	if (!filter_af_get(f, AF_UNIX))
 		return 0;
 
-	if (!unix_use_proc() && unix_show_netlink(f) == 0)
+	if (!getenv("PROC_NET_UNIX") && !getenv("PROC_ROOT")
+	    && unix_show_netlink(f) == 0)
 		return 0;
 
 	if ((fp = net_unix_open()) == NULL)
-- 
2.10.0
