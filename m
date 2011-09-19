From: <rongqing.li@windriver.com>
Subject: [PATCH 1/1] snmp6 relevant data structures are freed twice.
Date: Mon, 19 Sep 2011 15:03:13 +0800
Message-ID: <1316415793-2711-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37300 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab1ISHDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 03:03:16 -0400
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca [147.11.189.40])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id p8J73F5u005635
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 00:03:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

When calling snmp6_alloc_dev fails, the snmp6 relevant memory
are freed by snmp6_alloc_dev. Calling in6_dev_finish_destroy
will free these memory twice.

Double free will lead that undefined behavior occurs.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 net/ipv6/addrconf.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f1e5be..ba01f72 100644
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
