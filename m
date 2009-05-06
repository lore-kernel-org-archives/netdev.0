From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] net: update skb_recycle_check() for hardware timestamping changes
Date: Wed, 6 May 2009 13:13:11 +0200
Message-ID: <20090506111311.GD24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: patrick.ohly@intel.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53515 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbZEFLGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 07:06:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ac45f602ee3d1b6f326f68bc0c2591ceebf05ba4 ("net: infrastructure
for hardware time stamping") added two skb initialization actions to
__alloc_skb(), which need to be added to skb_recycle_check() as well.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Patrick Ohly <patrick.ohly@intel.com>
---
 net/core/skbuff.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f091a5a..d152394 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -502,7 +502,9 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 	shinfo->gso_segs = 0;
 	shinfo->gso_type = 0;
 	shinfo->ip6_frag_id = 0;
+	shinfo->tx_flags.flags = 0;
 	shinfo->frag_list = NULL;
+	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->data = skb->head + NET_SKB_PAD;
-- 
1.5.6.4
