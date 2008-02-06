From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 6/17] [NETNS]: Default arp parameters lookup.
Date: Wed,  6 Feb 2008 13:53:26 +0300
Message-ID: <1202295217-22769-6-git-send-email-den@openvz.org>
References: <47A99196.2030105@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:53558 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758168AbYBFKxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 05:53:15 -0500
In-Reply-To: <47A99196.2030105@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Default ARP parameters should be findable regardless of the context.
Required to make inetdev_event working.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/core/neighbour.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 1ed7b0a..ea44b8d 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1281,9 +1281,7 @@ static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
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

