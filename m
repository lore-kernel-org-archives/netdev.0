From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH net-next] skbuff: optimize the pull_pages code in __pskb_pull_tail()
Date: Thu,  6 Jul 2017 17:01:34 +0800
Message-ID: <1499331694-34678-1-git-send-email-xiaolou4617@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Lin Zhang <xiaolou4617@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35109 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdGFJBp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 05:01:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the pull_pages code block, if the first frags size > eat,
we can end the loop in advance to avoid extra copy.

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
 net/core/skbuff.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f990eb8..c00a1df 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1720,6 +1720,10 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
 				skb_shinfo(skb)->frags[k].page_offset += eat;
 				skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
 				eat = 0;
+				if (!i) {
+					k = skb_shinfo(skb)->nr_frags;
+					break;
+				}
 			}
 			k++;
 		}
-- 
1.8.3.1
