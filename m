From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] ipv4: Only destroy inet devices when we receive an NETDEV_UNREGISTER event
Date: Fri, 22 Jun 2007 00:42:34 -0600
Message-ID: <m17ipwebhh.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36722 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbXFVGmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 02:42:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currently we destroy inet devices when we remove the last interface
from an inet device, and during NETDEV_UNREGISTER.  We only create
them during NETDEV_REGISTER event.  The result is if you and an ipv4
address to a device delete it (so the device has no ipv4 addresses)
and attampt to add any ipv4 address to that device you will receive 
an -ENOBUFS error.

To correct the problem this patch simply deletes the excess inet
device destroy.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/devinet.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index fa97b96..abf6352 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -327,12 +327,8 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 		}
 
 	}
-	if (destroy) {
+	if (destroy)
 		inet_free_ifa(ifa1);
-
-		if (!in_dev->ifa_list)
-			inetdev_destroy(in_dev);
-	}
 }
 
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
-- 
1.5.1.1.181.g2de0

