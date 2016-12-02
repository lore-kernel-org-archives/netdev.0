From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 02/18] ss: Drop empty lines in UDP output
Date: Fri,  2 Dec 2016 11:39:46 +0100
Message-ID: <20161202104002.17310-3-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46773 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934132AbcLBKkv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:40:51 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dumping UDP sockets and show_tcpinfo (-i) is active but not
show_mem (-m), print_tcpinfo() does not output anything leading to an
empty line being printed after every socket. Fix this by skipping the
call to print_tcpinfo() and the previous newline printing in that case.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 469721fd9aee3..3871a6f61f8ea 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2412,7 +2412,7 @@ static int inet_show_sock(struct nlmsghdr *nlh,
 		}
 	}
 
-	if (show_mem || show_tcpinfo) {
+	if (show_mem || (show_tcpinfo && protocol != IPPROTO_UDP)) {
 		printf("\n\t");
 		if (protocol == IPPROTO_SCTP)
 			sctp_show_info(nlh, r, tb);
-- 
2.10.0
