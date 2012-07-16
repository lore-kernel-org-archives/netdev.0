From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: respect GFP_DMA in __netdev_alloc_skb()
Date: Mon, 16 Jul 2012 13:15:52 +0200
Message-ID: <1342437352.23494.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42186 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab2GPLP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 07:15:57 -0400
Received: by eaak11 with SMTP id k11so1609581eaa.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 04:15:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Few drivers use GFP_DMA allocations, and netdev_alloc_frag()
doesn't allocate pages in DMA zone.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 46a3d23..d124306 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -353,7 +353,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 	unsigned int fragsz = SKB_DATA_ALIGN(length + NET_SKB_PAD) +
 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
-	if (fragsz <= PAGE_SIZE && !(gfp_mask & __GFP_WAIT)) {
+	if (fragsz <= PAGE_SIZE && !(gfp_mask & (__GFP_WAIT | GFP_DMA))) {
 		void *data = netdev_alloc_frag(fragsz);
 
 		if (likely(data)) {
