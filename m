From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: remove two kmemcheck annotations
Date: Fri, 03 Sep 2010 18:27:08 +0200
Message-ID: <1283531228.2453.1162.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:32967 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204Ab0ICQ1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 12:27:12 -0400
Received: by ewy23 with SMTP id 23so1232697ewy.19
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 09:27:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__alloc_skb() uses a memset() to clear all the beginning of skb,
including bitfields contained in 'flags1' & 'flags2'.

We dont need any more to use kmemcheck_annotate_bitfield() on these
fields. However, we still need it for the clone part, which is not
cleared.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/skbuff.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 231dff0..c030cf8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -202,8 +202,6 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
 	skb->end = skb->tail + size;
-	kmemcheck_annotate_bitfield(skb, flags1);
-	kmemcheck_annotate_bitfield(skb, flags2);
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->mac_header = ~0U;
 #endif


