From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH] arping: Fix find_device_by_ifaddrs()
Date: Thu, 22 Nov 2012 09:51:15 +0100
Message-ID: <1353574275-21742-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12257 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756087Ab2KVTbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 14:31:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Look for another device if the device name and the currently found one are the
same, not different.

Also, make checking for the device's flags nonfatal.

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 arping.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arping.c b/arping.c
index ff77bec..d0edccf 100644
--- a/arping.c
+++ b/arping.c
@@ -550,10 +550,10 @@ static int find_device_by_ifaddrs(void)
 			continue;
 		if (ifa->ifa_addr->sa_family != AF_PACKET)
 			continue;
-		if (device.name && ifa->ifa_name && strcmp(ifa->ifa_name, device.name))
+		if (device.name && ifa->ifa_name && !strcmp(ifa->ifa_name, device.name))
 			continue;
 
-		if (check_ifflags(ifa->ifa_flags, device.name != NULL) < 0)
+		if (check_ifflags(ifa->ifa_flags, 0) < 0)
 			continue;
 
 		if (!((struct sockaddr_ll *)ifa->ifa_addr)->sll_halen)
-- 
1.7.11.7
