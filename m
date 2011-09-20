From: <rongqing.li@windriver.com>
Subject: [PATCH net-next] ipv6: fix a possible double free
Date: Tue, 20 Sep 2011 13:52:16 +0800
Message-ID: <1316497936-16901-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<stable@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57092 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845Ab1ITFwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 01:52:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

When calling snmp6_alloc_dev fails, the snmp6 relevant memory
are freed by snmp6_alloc_dev. Calling in6_dev_finish_destroy
will free these memory twice.

Double free will lead that undefined behavior occurs.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/addrconf.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f012ebd..12368c5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -374,8 +374,8 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 			"%s(): cannot allocate memory for statistics; dev=%s.\n",
 			__func__, dev->name));
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
-		ndev->dead = 1;
-		in6_dev_finish_destroy(ndev);
+		dev_put(dev);
+		kfree(ndev);
 		return NULL;
 	}
 
-- 
1.7.1
