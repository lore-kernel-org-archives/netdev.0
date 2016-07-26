From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipmr/ip6mr: update lastuse on entry change
Date: Tue, 26 Jul 2016 18:34:21 +0200
Message-ID: <1469550861-13032-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Donald Sharp <sharpd@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35994 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485AbcGZQe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 12:34:28 -0400
Received: by mail-wm0-f49.google.com with SMTP id q128so180473109wma.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 09:34:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently lastuse is updated on entry creation and cache hit, but it should
also be updated on entry change.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
CC: Donald Sharp <sharpd@cumulusnetworks.com>
CC: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipmr.c  | 1 +
 net/ipv6/ip6mr.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index eec234161b89..8f032428c14c 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1135,6 +1135,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 		if (!mrtsock)
 			c->mfc_flags |= MFC_STATIC;
 		write_unlock_bh(&mrt_lock);
+		c->mfc_un.res.lastuse = jiffies;
 		mroute_netlink_event(mrt, c, RTM_NEWROUTE);
 		return 0;
 	}
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 7adce139d92a..45c5b30a3a8a 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1485,6 +1485,7 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 		if (!mrtsock)
 			c->mfc_flags |= MFC_STATIC;
 		write_unlock_bh(&mrt_lock);
+		c->mfc_un.res.lastuse = jiffies;
 		mr6_netlink_event(mrt, c, RTM_NEWROUTE);
 		return 0;
 	}
-- 
2.1.4
