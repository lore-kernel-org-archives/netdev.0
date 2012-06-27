From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/7] ip6mr: Do not use RTA_PUT() macros
Date: Wed, 27 Jun 2012 11:36:14 +0200
Message-ID: <f67d0d7010ae44db3c594468b15834dcfc63191f.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33299 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697Ab2F0Jg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 05:36:27 -0400
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv6/ip6mr.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 461e47c..4532973 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2104,8 +2104,9 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	if (c->mf6c_parent >= MAXMIFS)
 		return -ENOENT;
 
-	if (MIF_EXISTS(mrt, c->mf6c_parent))
-		RTA_PUT(skb, RTA_IIF, 4, &mrt->vif6_table[c->mf6c_parent].dev->ifindex);
+	if (MIF_EXISTS(mrt, c->mf6c_parent) &&
+	    nla_put_u32(skb, RTA_IIF, mrt->vif6_table[c->mf6c_parent].dev->ifindex) < 0)
+		return -EMSGSIZE;
 
 	mp_head = (struct rtattr *)skb_put(skb, RTA_LENGTH(0));
 
-- 
1.7.7.6
