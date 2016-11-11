From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH iproute2 v1 2/2] iproute2: a non-expected rtnl message is an error
Date: Fri, 11 Nov 2016 10:55:37 -0800
Message-ID: <1478890537-88715-2-git-send-email-ddecotig@gmail.com>
References: <1478890537-88715-1-git-send-email-ddecotig@gmail.com>
Cc: netdev@vger.kernel.org, David Decotigny <ddecotig@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36752 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934591AbcKKTH5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 14:07:57 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so2489114pgx.3
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 11:07:57 -0800 (PST)
In-Reply-To: <1478890537-88715-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index dae793b..10d0afe 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -320,7 +320,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (n->nlmsg_type != RTM_NEWROUTE && n->nlmsg_type != RTM_DELROUTE) {
 		fprintf(stderr, "Not a route: %08x %08x %08x\n",
 			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
-		return 0;
+		return -1;
 	}
 	if (filter.flushb && n->nlmsg_type != RTM_NEWROUTE)
 		return 0;
-- 
2.8.0.rc3.226.g39d4020
