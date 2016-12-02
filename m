From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 13/18] ss: Get rid of useless goto in handle_follow_request()
Date: Fri,  2 Dec 2016 11:39:57 +0100
Message-ID: <20161202104002.17310-14-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33053 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934231AbcLBKlX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:41:23 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index c498478421190..ec71c21ce6a4a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3632,7 +3632,7 @@ static int generic_show_sock(const struct sockaddr_nl *addr,
 
 static int handle_follow_request(struct filter *f)
 {
-	int ret = -1;
+	int ret = 0;
 	int groups = 0;
 	struct rtnl_handle rth;
 
@@ -3655,10 +3655,8 @@ static int handle_follow_request(struct filter *f)
 	rth.local.nl_pid = 0;
 
 	if (rtnl_dump_filter(&rth, generic_show_sock, f))
-		goto Exit;
+		ret = -1;
 
-	ret = 0;
-Exit:
 	rtnl_close(&rth);
 	return ret;
 }
-- 
2.10.0
