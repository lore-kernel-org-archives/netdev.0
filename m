From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] net: skbuff: don't zero tc members when freeing skb
Date: Wed, 31 Dec 2014 13:33:41 +0100
Message-ID: <1420029221-4296-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59706 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750760AbaLaMdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 07:33:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not needed, only four cases:
 - kfree_skb (or one of its aliases).
   Don't need to zero, memory will be freed.
 - kfree_skb_partial and head was stolen:  memory will be freed.
 - skb_morph:  The skb header fields (including tc ones) will be
   copied over from the 'to-be-morphed' skb right after
   skb_release_head_state returns.
 - skb_segment:  Same as before, all the skb header
   fields are copied over from the original skb right away.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/skbuff.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ae13ef6..8e20bfa 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -677,13 +677,6 @@ static void skb_release_head_state(struct sk_buff *skb)
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	nf_bridge_put(skb->nf_bridge);
 #endif
-/* XXX: IS this still necessary? - JHS */
-#ifdef CONFIG_NET_SCHED
-	skb->tc_index = 0;
-#ifdef CONFIG_NET_CLS_ACT
-	skb->tc_verd = 0;
-#endif
-#endif
 }
 
 /* Free everything but the sk_buff shell. */
-- 
2.0.5
