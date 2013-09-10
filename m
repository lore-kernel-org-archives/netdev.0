From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next] net: sk_buff: memset(skb,0) after alloc in skb_clone
Date: Tue, 10 Sep 2013 10:18:53 +0530
Message-ID: <1378788533-5609-1-git-send-email-govindarajulu90@gmail.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:53682 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066Ab3IJEs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 00:48:59 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf1so7237657pab.10
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 21:48:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch memset the skb to 0 after alloc. We do this in
__alloc_skb_head, __alloc_skb, build_skb. We are missing this in
skb_clone.

The following call to __skb_clone in skb_clone does not copy all the
members of sk_buff. If we donot clear the skb to 0, we will have some
uninitialized members in new skb.

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 net/core/skbuff.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d81cff1..fc78f66 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -891,6 +891,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)
 			return NULL;
+		memset(n, 0, offsetof(struct sk_buff, tail));
 
 		kmemcheck_annotate_bitfield(n, flags1);
 		kmemcheck_annotate_bitfield(n, flags2);
-- 
1.8.4
