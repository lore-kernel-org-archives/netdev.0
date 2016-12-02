From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 03/18] ss: Add missing tab when printing UNIX details
Date: Fri,  2 Dec 2016 11:39:47 +0100
Message-ID: <20161202104002.17310-4-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47689 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934056AbcLBKk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:40:26 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dumping UNIX sockets and show_details is active but not show_mem
(ss -xne), the socket details are printed without being prefixed by tab.
Fix this by printing the tab character when either one of '-e' or '-m'
has been specified.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 3871a6f61f8ea..f1053b1db4132 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3096,10 +3096,10 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 
 	unix_stats_print(&stat, f);
 
-	if (show_mem) {
+	if (show_mem || show_details)
 		printf("\t");
+	if (show_mem)
 		print_skmeminfo(tb, UNIX_DIAG_MEMINFO);
-	}
 	if (show_details) {
 		if (tb[UNIX_DIAG_SHUTDOWN]) {
 			unsigned char mask;
-- 
2.10.0
