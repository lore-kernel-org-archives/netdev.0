From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 02/18] ss: Drop empty lines in UDP output
Date: Fri, 11 Nov 2016 14:09:58 +0100
Message-ID: <20161111131014.21865-3-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59098 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932967AbcKKNMT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:12:19 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
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
index c20bfbdb01c62..4698683c4e84a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2240,7 +2240,7 @@ static int inet_show_sock(struct nlmsghdr *nlh,
 		}
 	}
 
-	if (show_mem || show_tcpinfo) {
+	if (show_mem || (show_tcpinfo && protocol != IPPROTO_UDP)) {
 		printf("\n\t");
 		tcp_show_info(nlh, r, tb);
 	}
-- 
2.10.0
