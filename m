From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 3/4] ss: show destination address for netlink sockets
Date: Wed,  5 Jun 2013 12:42:00 +0400
Message-ID: <1370421721-30814-4-git-send-email-avagin@openvz.org>
References: <1370421721-30814-1-git-send-email-avagin@openvz.org>
Cc: netdev@vger.kernel.org, Andrey Vagin <avagin@openvz.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26012 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753443Ab3FEIoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 04:44:23 -0400
In-Reply-To: <1370421721-30814-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A netlink socket may be connected to a specific group.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 misc/ss.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 469ffd0..c8534ff 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2674,6 +2674,7 @@ static int packet_show(struct filter *f)
 
 static void netlink_show_one(struct filter *f,
 				int prot, int pid, unsigned groups,
+				int state, int dst_pid, unsigned dst_group,
 				int rq, int wq,
 				unsigned long long sk, unsigned long long cb)
 {
@@ -2728,8 +2729,14 @@ static void netlink_show_one(struct filter *f,
 	} else {
 		printf("%-*d ", serv_width, pid);
 	}
-	printf("%*s*%-*s",
-	       addr_width, "", serv_width, "");
+
+	if (state == NETLINK_CONNECTED) {
+		printf("%*d:%-*d",
+		       addr_width, dst_group, serv_width, dst_pid);
+	} else {
+		printf("%*s*%-*s",
+		       addr_width, "", serv_width, "");
+	}
 
 	if (show_details) {
 		printf(" sk=%llx cb=%llx groups=0x%08x", sk, cb, groups);
@@ -2764,7 +2771,7 @@ static int netlink_show(struct filter *f)
 		       &sk,
 		       &prot, &pid, &groups, &rq, &wq, &cb, &rc);
 
-		netlink_show_one(f, prot, pid, groups, rq, wq, sk, cb);
+		netlink_show_one(f, prot, pid, groups, 0, 0, 0, rq, wq, sk, cb);
 	}
 
 	return 0;
-- 
1.8.1.4
