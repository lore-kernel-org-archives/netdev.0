From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH net-next resubmit] skbuff: optimize the pull_pages code in __pskb_pull_tail()
Date: Mon, 17 Jul 2017 10:22:06 +0800
Message-ID: <1500258126-11235-1-git-send-email-xiaolou4617@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Lin Zhang <xiaolou4617@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the pull_pages code block, if the first frag size > eat,
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
