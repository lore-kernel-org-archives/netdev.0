From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: ipmr/ip6mr: update lastuse on entry change
Date: Tue, 26 Jul 2016 18:54:52 +0200
Message-ID: <1469552092-16019-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1469550861-13032-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Donald Sharp <sharpd@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36358 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757170AbcGZQzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 12:55:02 -0400
Received: by mail-wm0-f41.google.com with SMTP id q128so181141149wma.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 09:55:01 -0700 (PDT)
In-Reply-To: <1469550861-13032-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently lastuse is updated on entry creation and cache hit, but it should
also be updated on entry change. Since both on add and update the ttl array
is updated we can simply update the lastuse in ipmr_update_thresholds.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
CC: Donald Sharp <sharpd@cumulusnetworks.com>
CC: David S. Miller <davem@davemloft.net>
---
v2: instead of duplicating the lastuse update, do it while updating the
thresholds which is shared by add/update

 net/ipv4/ipmr.c  | 2 +-
 net/ipv6/ip6mr.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index eec234161b89..26253328d227 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -722,6 +722,7 @@ static void ipmr_update_thresholds(struct mr_table *mrt, struct mfc_cache *cache
 				cache->mfc_un.res.maxvif = vifi + 1;
 		}
 	}
+	cache->mfc_un.res.lastuse = jiffies;
 }
 
 static int vif_add(struct net *net, struct mr_table *mrt,
@@ -1150,7 +1151,6 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 	c->mfc_origin = mfc->mfcc_origin.s_addr;
 	c->mfc_mcastgrp = mfc->mfcc_mcastgrp.s_addr;
 	c->mfc_parent = mfc->mfcc_parent;
-	c->mfc_un.res.lastuse = jiffies;
 	ipmr_update_thresholds(mrt, c, mfc->mfcc_ttls);
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 7adce139d92a..6122f9c5cc49 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -921,6 +921,7 @@ static void ip6mr_update_thresholds(struct mr6_table *mrt, struct mfc6_cache *ca
 				cache->mfc_un.res.maxvif = vifi + 1;
 		}
 	}
+	cache->mfc_un.res.lastuse = jiffies;
 }
 
 static int mif6_add(struct net *net, struct mr6_table *mrt,
@@ -1500,7 +1501,6 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 	c->mf6c_origin = mfc->mf6cc_origin.sin6_addr;
 	c->mf6c_mcastgrp = mfc->mf6cc_mcastgrp.sin6_addr;
 	c->mf6c_parent = mfc->mf6cc_parent;
-	c->mfc_un.res.lastuse = jiffies;
 	ip6mr_update_thresholds(mrt, c, ttls);
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
-- 
2.1.4
