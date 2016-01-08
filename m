From: Lorenzo Colitti <lorenzo@google.com>
Subject: [iproute PATCH v4 1/2] libnetlink: don't print NETLINK_SOCK_DIAG errors in rtnl_talk
Date: Fri,  8 Jan 2016 17:32:36 +0900
Message-ID: <1452241957-18854-2-git-send-email-lorenzo@google.com>
References: <CAKD1Yr1VQxVkQKpGxrtGmWd=_Z9Q2eBp1L313bqSddDXG9nNxg@mail.gmail.com>
 <1452241957-18854-1-git-send-email-lorenzo@google.com>
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34812 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269AbcAHIcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 03:32:47 -0500
Received: by mail-pa0-f45.google.com with SMTP id uo6so260640356pac.1
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 00:32:47 -0800 (PST)
In-Reply-To: <1452241957-18854-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is a no-op, as currently no code uses rtnl_talk on
NETLINK_SOCK_DIAG_BY_FAMILY sockets. It is needed to suppress
spurious errors when using SOCK_DESTROY via rtnl_talk.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 lib/libnetlink.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 1658214..d6b5fd3 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -419,8 +419,10 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 					return 0;
 				}
 
-				fprintf(stderr, "RTNETLINK answers: %s\n",
-					strerror(-err->error));
+				if (rtnl->proto != NETLINK_SOCK_DIAG)
+					fprintf(stderr,
+						"RTNETLINK answers: %s\n",
+						strerror(-err->error));
 				errno = -err->error;
 				return -1;
 			}
-- 
2.6.0.rc2.230.g3dd15c0
