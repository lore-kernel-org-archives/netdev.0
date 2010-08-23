From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] bridge: netfilter: fix a memory leak
Date: Mon, 23 Aug 2010 13:03:26 +0800
Message-ID: <1282539806-25496-1-git-send-email-xiaosuo@gmail.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:35638 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682Ab0HWFEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 01:04:09 -0400
Received: by pvg2 with SMTP id 2so2135379pvg.19
        for <netdev@vger.kernel.org>; Sun, 22 Aug 2010 22:04:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_bridge_alloc() always reset the skb->nf_bridge, so we should always
put the old one.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v2: Should init tmp->use again because memcpy() overwrite it.
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 2c911c0..5ed00bd 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -162,8 +162,8 @@ static inline struct nf_bridge_info *nf_bridge_unshare(struct sk_buff *skb)
 		if (tmp) {
 			memcpy(tmp, nf_bridge, sizeof(struct nf_bridge_info));
 			atomic_set(&tmp->use, 1);
-			nf_bridge_put(nf_bridge);
 		}
+		nf_bridge_put(nf_bridge);
 		nf_bridge = tmp;
 	}
 	return nf_bridge;
