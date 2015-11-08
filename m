From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 6/6] iptoken: simplify iptoken_list a bit
Date: Sun,  8 Nov 2015 21:22:21 +0100
Message-ID: <1447014141-3565-7-git-send-email-phil@nwl.cc>
References: <1447010471-559-1-git-send-email-phil@nwl.cc>
 <1447014141-3565-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53222 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751504AbbKHUWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Nov 2015 15:22:25 -0500
In-Reply-To: <1447014141-3565-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since it uses only a single filter, rtnl_dump_filter() can be used.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iptoken.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/ip/iptoken.c b/ip/iptoken.c
index a38194c..428f133 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -95,10 +95,6 @@ static int iptoken_list(int argc, char **argv)
 {
 	int af = AF_INET6;
 	struct rtnl_dump_args da;
-	const struct rtnl_dump_filter_arg a[2] = {
-		{ .filter = print_token, .arg1 = &da, },
-		{ .filter = NULL, .arg1 = NULL, },
-	};
 
 	memset(&da, 0, sizeof(da));
 	da.fp = stdout;
@@ -118,7 +114,7 @@ static int iptoken_list(int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_dump_filter_l(&rth, a) < 0) {
+	if (rtnl_dump_filter(&rth, print_token, &da) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		return -1;
 	}
-- 
2.1.2
