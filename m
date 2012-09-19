From: roy.qing.li@gmail.com
Subject: [PATCH] net/core: fix comment in skb_try_coalesce
Date: Wed, 19 Sep 2012 10:53:21 +0800
Message-ID: <1348023201-7727-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:37718 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab2ISCx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 22:53:29 -0400
Received: by pbbrr13 with SMTP id rr13so1342487pbb.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 19:53:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

It should be the skb which is not cloned

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/skbuff.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fe00d12..354a4e4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3502,7 +3502,9 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 	if (!skb_cloned(from))
 		skb_shinfo(from)->nr_frags = 0;
 
-	/* if the skb is cloned this does nothing since we set nr_frags to 0 */
+	/* if the skb is not cloned this does nothing
+	 * since we set nr_frags to 0.
+	 */
 	for (i = 0; i < skb_shinfo(from)->nr_frags; i++)
 		skb_frag_ref(from, i);
 
-- 
1.7.4.1
