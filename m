From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/3] netfilter: nfnetlink: don't probe module if it exists
Date: Wed,  4 Nov 2015 15:00:38 +0100
Message-ID: <1446645638-3625-4-git-send-email-pablo@netfilter.org>
References: <1446645638-3625-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44242 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932631AbbKDNxr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 08:53:47 -0500
In-Reply-To: <1446645638-3625-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

nfnetlink_bind request_module()s all the time as nfnetlink_get_subsys()
shifts the argument by 8 to obtain the subsys id.

So using type instead of type << 8 always returns NULL.

Fixes: 03292745b02d11 ("netlink: add nlk->netlink_bind hook for module auto-loading")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 70277b1..27b93da 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -492,7 +492,7 @@ static int nfnetlink_bind(struct net *net, int group)
 	type = nfnl_group2type[group];
 
 	rcu_read_lock();
-	ss = nfnetlink_get_subsys(type);
+	ss = nfnetlink_get_subsys(type << 8);
 	rcu_read_unlock();
 	if (!ss)
 		request_module("nfnetlink-subsys-%d", type);
-- 
2.1.4
