From: gfree.wind@vip.163.com
Subject: [PATCH net-next ] net: Remove useless function skb_header_release
Date: Thu, 21 Sep 2017 12:39:31 +0800
Message-ID: <1505968771-92232-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-177180.vip.163.com ([123.58.177.180]:44297 "EHLO
        mail-177180.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdIUEjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 00:39:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

There is no one which would invokes the function skb_header_release.
So just remove it now.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 include/linux/skbuff.h | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 72299ef..ce632cd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1457,22 +1457,6 @@ static inline int skb_header_unclone(struct sk_buff *skb, gfp_t pri)
 }
 
 /**
- *	skb_header_release - release reference to header
- *	@skb: buffer to operate on
- *
- *	Drop a reference to the header part of the buffer.  This is done
- *	by acquiring a payload reference.  You must not read from the header
- *	part of skb->data after this.
- *	Note : Check if you can use __skb_header_release() instead.
- */
-static inline void skb_header_release(struct sk_buff *skb)
-{
-	BUG_ON(skb->nohdr);
-	skb->nohdr = 1;
-	atomic_add(1 << SKB_DATAREF_SHIFT, &skb_shinfo(skb)->dataref);
-}
-
-/**
  *	__skb_header_release - release reference to header
  *	@skb: buffer to operate on
  *
-- 
1.9.1
