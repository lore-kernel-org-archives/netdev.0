From: <rongqing.li@windriver.com>
Subject: [PATCH] Ipv6: Delete rcu_read_lock
Date: Thu, 29 Sep 2011 15:46:54 +0800
Message-ID: <1317282414-13368-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50588 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655Ab1I2Hqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 03:46:53 -0400
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca [147.11.189.40])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id p8T7kqK3022241
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Sep 2011 00:46:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

Delete rcu_read_lock, it is redundant.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 net/ipv6/ndisc.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 9da6e02..dd633ff 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -370,17 +370,14 @@ static int ndisc_constructor(struct neighbour *neigh)
 	struct neigh_parms *parms;
 	int is_multicast = ipv6_addr_is_multicast(addr);
 
-	rcu_read_lock();
 	in6_dev = in6_dev_get(dev);
 	if (in6_dev == NULL) {
-		rcu_read_unlock();
 		return -EINVAL;
 	}
 
 	parms = in6_dev->nd_parms;
 	__neigh_parms_put(neigh->parms);
 	neigh->parms = neigh_parms_clone(parms);
-	rcu_read_unlock();
 
 	neigh->type = is_multicast ? RTN_MULTICAST : RTN_UNICAST;
 	if (!dev->header_ops) {
-- 
1.7.1
