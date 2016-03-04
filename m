From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] libnetlink: Double the dump buffer size
Date: Fri,  4 Mar 2016 19:57:28 +0100
Message-ID: <1457117848-22216-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40859 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759462AbcCDS5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 13:57:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There have been reports about 'ip addr' printing "Message truncated" on
systems with large numbers of VFs. Although I haven't been able to get
my hands on hardware suitable to reproduce this, increasing the dump
buffer has been reported to resolve the issue. For want of a better
idea, just double the buffer size to 32k.

Feels like this opportunistic buffer size selection is rather
workarounding a design flaw in libnetlink or maybe even the netlink
protocol itself.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/libnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index d6b5fd3e8a493..245c4ca216753 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -223,7 +223,7 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char buf[16384];
+	char buf[32768];
 	int dump_intr = 0;
 
 	iov.iov_base = buf;
-- 
2.7.2
