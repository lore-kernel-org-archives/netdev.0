From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v3 RESEND 1/3] neigh: no need to call lookup_neigh_parms in neigh_parms_alloc
Date: Thu, 20 Jun 2013 10:01:32 +0800
Message-ID: <1371693694-18531-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52544 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S935237Ab3FTCAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 22:00:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

neigh_table.parms always exist and is initialized,kmemdup
can use it to create new neigh_parms, actually lookup_neigh_parms
here will return neigh_table.parms too.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/core/neighbour.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 5c56b21..62d9757 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1429,15 +1429,11 @@ static inline struct neigh_parms *lookup_neigh_parms(struct neigh_table *tbl,
 struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 				      struct neigh_table *tbl)
 {
-	struct neigh_parms *p, *ref;
+	struct neigh_parms *p;
 	struct net *net = dev_net(dev);
 	const struct net_device_ops *ops = dev->netdev_ops;
 
-	ref = lookup_neigh_parms(tbl, net, 0);
-	if (!ref)
-		return NULL;
-
-	p = kmemdup(ref, sizeof(*p), GFP_KERNEL);
+	p = kmemdup(&tbl->parms, sizeof(*p), GFP_KERNEL);
 	if (p) {
 		p->tbl		  = tbl;
 		atomic_set(&p->refcnt, 1);
-- 
1.8.1.4
