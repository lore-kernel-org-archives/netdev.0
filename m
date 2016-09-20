From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: [PATCH v3 net-next 2/2] net: skbuff: Coding: Use eth_type_vlan() instead of open coding it
Date: Tue, 20 Sep 2016 12:48:37 +0300
Message-ID: <1474364917-31710-2-git-send-email-shmulik.ladkani@gmail.com>
References: <1474364917-31710-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Pravin Shelar <pshelar@ovn.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38281 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932616AbcITJti (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:49:38 -0400
Received: by mail-wm0-f50.google.com with SMTP id l132so25061166wmf.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:49:32 -0700 (PDT)
In-Reply-To: <1474364917-31710-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix 'skb_vlan_pop' to use eth_type_vlan instead of directly comparing
skb->protocol to ETH_P_8021Q or ETH_P_8021AD.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 net/core/skbuff.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 93d6c5c..d6d0da5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4564,8 +4564,7 @@ int skb_vlan_pop(struct sk_buff *skb)
 	if (likely(skb_vlan_tag_present(skb))) {
 		skb->vlan_tci = 0;
 	} else {
-		if (unlikely(skb->protocol != htons(ETH_P_8021Q) &&
-			     skb->protocol != htons(ETH_P_8021AD)))
+		if (unlikely(!eth_type_vlan(skb->protocol)))
 			return 0;
 
 		err = __skb_vlan_pop(skb, &vlan_tci);
@@ -4573,8 +4572,7 @@ int skb_vlan_pop(struct sk_buff *skb)
 			return err;
 	}
 	/* move next vlan tag to hw accel tag */
-	if (likely(skb->protocol != htons(ETH_P_8021Q) &&
-		   skb->protocol != htons(ETH_P_8021AD)))
+	if (likely(!eth_type_vlan(skb->protocol)))
 		return 0;
 
 	vlan_proto = skb->protocol;
-- 
1.9.1
