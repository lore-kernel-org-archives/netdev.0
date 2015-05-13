From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] netns: fix unbalanced spin_lock on error
Date: Wed, 13 May 2015 13:43:09 +0200
Message-ID: <1431517389-19937-1-git-send-email-nicolas.dichtel@6wind.com>
References: <55533771.6080406@6wind.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36399 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875AbbEMLn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 07:43:28 -0400
In-Reply-To: <55533771.6080406@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlock was missing on error path.

Fixes: 95f38411df05 ("netns: use a spin_lock to protect nsid management")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/net_namespace.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index a665bf490c88..cb32c0378c10 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -565,6 +565,7 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	spin_lock_irqsave(&nsid_lock, flags);
 	if (__peernet2id(net, peer) >= 0) {
+		spin_unlock_irqrestore(&nsid_lock, flags);
 		err = -EEXIST;
 		goto out;
 	}
-- 
2.2.2
