From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 13/18] ss: Get rid of useless goto in handle_follow_request()
Date: Fri, 11 Nov 2016 14:10:09 +0100
Message-ID: <20161111131014.21865-14-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44956 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932825AbcKKNMM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:12:12 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index c3a5148e05013..b06b9e6fa9884 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3443,7 +3443,7 @@ static int generic_show_sock(const struct sockaddr_nl *addr,
 
 static int handle_follow_request(struct filter *f)
 {
-	int ret = -1;
+	int ret = 0;
 	int groups = 0;
 	struct rtnl_handle rth;
 
@@ -3466,10 +3466,8 @@ static int handle_follow_request(struct filter *f)
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
