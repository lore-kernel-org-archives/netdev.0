From: kaber@trash.net
Subject: [PATCH 28/28] netfilter: nf_conntrack_acct: use skb->len for accounting
Date: Mon,  2 Aug 2010 21:57:45 +0200
Message-ID: <1280779065-9333-29-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35365 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872Ab0HBT6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:58:04 -0400
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

use skb->len for accounting as xt_quota does. Since nf_conntrack works
at the network layer, skb_network_offset should always returns ZERO.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_core.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 16b41b4..df3eedb 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -966,8 +966,7 @@ acct:
 		if (acct) {
 			spin_lock_bh(&ct->lock);
 			acct[CTINFO2DIR(ctinfo)].packets++;
-			acct[CTINFO2DIR(ctinfo)].bytes +=
-				skb->len - skb_network_offset(skb);
+			acct[CTINFO2DIR(ctinfo)].bytes += skb->len;
 			spin_unlock_bh(&ct->lock);
 		}
 	}
-- 
1.7.1

