From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 21/51] lib/libnetlink: Don't pass NULL parameter to memcpy()
Date: Sat, 12 Aug 2017 14:04:40 +0200
Message-ID: <20170812120510.28750-22-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49565 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752318AbdHLMFm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:05:42 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both addattr_l() and rta_addattr_l() may be called with NULL data
pointer and 0 alen parameters. Avoid calling memcpy() in that case.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/libnetlink.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 81a344abff27a..5e3adade77077 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -866,7 +866,8 @@ int addattr_l(struct nlmsghdr *n, int maxlen, int type, const void *data,
 	rta = NLMSG_TAIL(n);
 	rta->rta_type = type;
 	rta->rta_len = len;
-	memcpy(RTA_DATA(rta), data, alen);
+	if (alen)
+		memcpy(RTA_DATA(rta), data, alen);
 	n->nlmsg_len = NLMSG_ALIGN(n->nlmsg_len) + RTA_ALIGN(len);
 	return 0;
 }
@@ -953,7 +954,8 @@ int rta_addattr_l(struct rtattr *rta, int maxlen, int type,
 	subrta = (struct rtattr *)(((char *)rta) + RTA_ALIGN(rta->rta_len));
 	subrta->rta_type = type;
 	subrta->rta_len = len;
-	memcpy(RTA_DATA(subrta), data, alen);
+	if (alen)
+		memcpy(RTA_DATA(subrta), data, alen);
 	rta->rta_len = NLMSG_ALIGN(rta->rta_len) + RTA_ALIGN(len);
 	return 0;
 }
-- 
2.13.1
