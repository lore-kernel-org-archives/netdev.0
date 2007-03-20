From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 1/1] [SK_BUFF]: Adjust the zeroing up to tail in __alloc_skb too
Date: Tue, 20 Mar 2007 20:05:00 -0300
Message-ID: <20070320230500.GV17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:33228 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbXCTXFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:05:05 -0400
Received: by wx-out-0506.google.com with SMTP id h31so64322wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:05:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I did it just in alloc_skb_from_cache, forgot __alloc_skb, fixed now.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/core/skbuff.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c274ea3..d7d2dc3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -164,7 +164,10 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	if (!data)
 		goto nodata;
 
-	memset(skb, 0, offsetof(struct sk_buff, truesize));
+	/*
+	 * See comment in sk_buff definition, just before the 'tail' member
+	 */
+	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize = size + sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 	skb->head = data;
-- 
1.5.0.3

