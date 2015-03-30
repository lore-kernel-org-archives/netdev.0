From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: rename dev to orig_dev in deliver_ptype_list_skb
Date: Mon, 30 Mar 2015 16:56:01 +0200
Message-ID: <1427727361-3138-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:33006 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbbC3O4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 10:56:06 -0400
Received: by wgbgs4 with SMTP id gs4so87098785wgb.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 07:56:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike other places, this function uses name "dev" for what should be
"orig_dev", which might be a bit confusing. So fix this.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/dev.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3a06003..65492b0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1740,7 +1740,8 @@ static inline int deliver_skb(struct sk_buff *skb,
 
 static inline void deliver_ptype_list_skb(struct sk_buff *skb,
 					  struct packet_type **pt,
-					  struct net_device *dev, __be16 type,
+					  struct net_device *orig_dev,
+					  __be16 type,
 					  struct list_head *ptype_list)
 {
 	struct packet_type *ptype, *pt_prev = *pt;
@@ -1749,7 +1750,7 @@ static inline void deliver_ptype_list_skb(struct sk_buff *skb,
 		if (ptype->type != type)
 			continue;
 		if (pt_prev)
-			deliver_skb(skb, pt_prev, dev);
+			deliver_skb(skb, pt_prev, orig_dev);
 		pt_prev = ptype;
 	}
 	*pt = pt_prev;
-- 
1.9.3
