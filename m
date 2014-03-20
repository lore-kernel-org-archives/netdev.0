From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH iproute2] bridge: fix reporting of IPv6 addresses
Date: Thu, 20 Mar 2014 13:06:10 +0200
Message-ID: <1395313570-12545-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: netdev@vger.kernel.org,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:62030 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940AbaCTLGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 07:06:17 -0400
Received: by mail-ee0-f49.google.com with SMTP id c41so519537eek.8
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 04:06:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 bridge/fdb.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index e2e53f1..9b720e3 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -103,8 +103,13 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[NDA_DST]) {
 		SPRINT_BUF(abuf);
+		int family = AF_INET;
+
+		if (RTA_PAYLOAD(tb[NDA_DST]) == sizeof(struct in6_addr))
+			family = AF_INET6;
+
 		fprintf(fp, "dst %s ",
-			format_host(AF_INET,
+			format_host(family,
 				    RTA_PAYLOAD(tb[NDA_DST]),
 				    RTA_DATA(tb[NDA_DST]),
 				    abuf, sizeof(abuf)));
-- 
1.8.1.5
