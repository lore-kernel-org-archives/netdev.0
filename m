From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] core: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:37:32 +0800
Message-ID: <49A51F6C.4080603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60885 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1762516AbZBYKiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:38:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/core/neighbour.c |    6 ++----
 net/core/skbuff.c    |    3 +--
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 278a142..01221de 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -871,8 +871,7 @@ static void neigh_timer_handler(unsigned long arg)
 		write_unlock(&neigh->lock);
 		neigh->ops->solicit(neigh, skb);
 		atomic_inc(&neigh->probes);
-		if (skb)
-			kfree_skb(skb);
+		kfree_skb(skb);
 	} else {
 out:
 		write_unlock(&neigh->lock);
@@ -908,8 +907,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 			neigh->updated = jiffies;
 			write_unlock_bh(&neigh->lock);
 
-			if (skb)
-				kfree_skb(skb);
+			kfree_skb(skb);
 			return 1;
 		}
 	} else if (neigh->nud_state & NUD_STALE) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e5a8351..caf64c1 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1216,8 +1216,7 @@ unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)
 					insp = list;
 				}
 				if (!pskb_pull(list, eat)) {
-					if (clone)
-						kfree_skb(clone);
+					kfree_skb(clone);
 					return NULL;
 				}
 				break;
-- 
1.5.3.8




