From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] skbuff: make skb_put_zero() return void
Date: Wed, 14 Jun 2017 22:17:20 +0200
Message-ID: <20170614201720.21070-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:41422 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752004AbdFNURY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 16:17:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

It's nicer to return void, since then there's no need to
cast to any structures. Currently none of the users have
a cast, but a number of future conversions do.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/skbuff.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1151b50892d1..01ea64d0783a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1904,9 +1904,9 @@ static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 	return tmp;
 }
 
-static inline unsigned char *skb_put_zero(struct sk_buff *skb, unsigned int len)
+static inline void *skb_put_zero(struct sk_buff *skb, unsigned int len)
 {
-	unsigned char *tmp = skb_put(skb, len);
+	void *tmp = skb_put(skb, len);
 
 	memset(tmp, 0, len);
 
-- 
2.11.0
