From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 6/17 net-2.6.26] [NETNS]: Default arp parameters lookup.
Date: Tue, 19 Feb 2008 10:31:26 +0300
Message-ID: <1203406297-32725-6-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:63198 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754714AbYBSHbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:31:15 -0500
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Default ARP parameters should be findable regardless of the context.
Required to make inetdev_event working.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/core/neighbour.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c895ad4..45ed620 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1275,9 +1275,7 @@ static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
 	struct neigh_parms *p;
 
 	for (p = &tbl->parms; p; p = p->next) {
-		if (p->net != net)
-			continue;
-		if ((p->dev && p->dev->ifindex == ifindex) ||
+		if ((p->dev && p->dev->ifindex == ifindex && p->net == net) ||
 		    (!p->dev && !ifindex))
 			return p;
 	}
-- 
1.5.3.rc5

