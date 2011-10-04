From: <rongqing.li@windriver.com>
Subject: [PATCH net-next] ipv6: remove a rcu_read_lock in ndisc_constructor
Date: Tue, 4 Oct 2011 13:43:35 +0800
Message-ID: <1317707015-2432-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35390 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab1JDFni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 01:43:38 -0400
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca [147.11.189.40])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id p945hbbN022537
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 3 Oct 2011 22:43:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

in6_dev_get(dev) takes a reference on struct inet6_dev, we dont need
rcu locking in ndisc_constructor()

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
