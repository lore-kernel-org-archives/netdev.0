From: kaber@trash.net
Subject: [PATCH 66/79] netfilter: xt_connlimit: use hotdrop jump mark
Date: Wed, 19 Jan 2011 20:15:06 +0100
Message-ID: <1295464519-21763-67-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51989 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910Ab1ASTPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:40 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Weinberger <richard@nod.at>

Signed-off-by: Richard Weinberger <richard@nod.at>
Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_connlimit.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 5c5b6b9..452bc16 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -204,11 +204,9 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	                         &info->mask, par->family);
 	spin_unlock_bh(&info->data->lock);
 
-	if (connections < 0) {
+	if (connections < 0)
 		/* kmalloc failed, drop it entirely */
-		par->hotdrop = true;
-		return false;
-	}
+		goto hotdrop;
 
 	return (connections > info->limit) ^ info->inverse;
 
-- 
1.7.2.3

