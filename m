From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] rtnetlink: fix FDB size computation
Date: Fri, 18 Nov 2016 15:50:39 +0100
Message-ID: <9bef2a8afa6f8193fcca61ea381b67a52ab878b2.1479477903.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Hubert Sokolowski <hubert.sokolowski@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18342 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751180AbcKROuo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Nov 2016 09:50:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing NDA_VLAN attribute's size.

Fixes: 1e53d5bb8878 ("net: Pass VLAN ID to rtnl_fdb_notify.")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/core/rtnetlink.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2a75127f0e9e..92e75af2dc6a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2863,7 +2863,10 @@ static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
 
 static inline size_t rtnl_fdb_nlmsg_size(void)
 {
-	return NLMSG_ALIGN(sizeof(struct ndmsg)) + nla_total_size(ETH_ALEN);
+	return NLMSG_ALIGN(sizeof(struct ndmsg)) +
+	       nla_total_size(ETH_ALEN) +	/* NDA_LLADDR */
+	       nla_total_size(sizeof(u16)) +	/* NDA_VLAN */
+	       0;
 }
 
 static void rtnl_fdb_notify(struct net_device *dev, u8 *addr, u16 vid, int type,
-- 
2.10.2
