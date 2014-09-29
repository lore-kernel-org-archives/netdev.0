From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/34] netfilter: nfnetlink: use original skbuff when committing/aborting
Date: Mon, 29 Sep 2014 14:39:17 +0200
Message-ID: <1411994363-8451-29-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34352 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754281AbaI2Mi5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:38:57 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows us to access the original content of the batch from
the commit and the abort paths.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index c138b8f..f77d3f7 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -333,7 +333,7 @@ replay:
 			 * original skb.
 			 */
 			if (err == -EAGAIN) {
-				ss->abort(skb);
+				ss->abort(oskb);
 				nfnl_unlock(subsys_id);
 				kfree_skb(nskb);
 				goto replay;
@@ -357,9 +357,9 @@ ack:
 	}
 done:
 	if (success && done)
-		ss->commit(skb);
+		ss->commit(oskb);
 	else
-		ss->abort(skb);
+		ss->abort(oskb);
 
 	nfnl_unlock(subsys_id);
 	kfree_skb(nskb);
-- 
1.7.10.4
