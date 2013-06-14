From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v2 2/4] neigh: only allow init_net to change the default neigh_parms
Date: Fri, 14 Jun 2013 10:06:45 +0800
Message-ID: <1371175607-1405-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1371175607-1405-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55822 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758933Ab3FNCFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 22:05:13 -0400
In-Reply-To: <1371175607-1405-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Though we don't export the /proc/sys/net/ipv[4,6]/neigh/default/
directory to the un-init_net, but we can still use cmd such as
"ip ntable change name arp_cache locktime 129" to change the locktime
of default neigh_parms.

This patch disallows the un-init_net to find out the neigh_table.parms.
So the un-init_net will failed to influence the init_net.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/core/neighbour.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 62d9757..2ec1faf 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1419,7 +1419,7 @@ static inline struct neigh_parms *lookup_neigh_parms(struct neigh_table *tbl,
 
 	for (p = &tbl->parms; p; p = p->next) {
 		if ((p->dev && p->dev->ifindex == ifindex && net_eq(neigh_parms_net(p), net)) ||
-		    (!p->dev && !ifindex))
+		    (!p->dev && !ifindex && net_eq(net, &init_net)))
 			return p;
 	}
 
-- 
1.8.1.4
