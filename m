From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v2 2/2] net: skbuff: Coding: Use eth_type_vlan() instead of open coding it
Date: Mon, 19 Sep 2016 18:53:20 +0300
Message-ID: <1474300400-32362-2-git-send-email-shmulik.ladkani@gmail.com>
References: <1474300400-32362-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35273 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751414AbcISPx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 11:53:58 -0400
Received: by mail-wm0-f66.google.com with SMTP id 133so15710086wmq.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 08:53:58 -0700 (PDT)
In-Reply-To: <1474300400-32362-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix 'skb_vlan_pop' to use eth_type_vlan instead of directly comparing
skb->protocol to ETH_P_8021Q or ETH_P_8021AD.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 net/core/skbuff.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4dbaedb745..1369faa182 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4535,8 +4535,7 @@ int skb_vlan_pop(struct sk_buff *skb)
 	if (likely(skb_vlan_tag_present(skb))) {
 		skb->vlan_tci = 0;
 	} else {
-		if (unlikely(skb->protocol != htons(ETH_P_8021Q) &&
-			     skb->protocol != htons(ETH_P_8021AD)))
+		if (unlikely(!eth_type_vlan(skb->protocol)))
 			return 0;
 
 		err = __skb_vlan_pop(skb, &vlan_tci);
@@ -4544,8 +4543,7 @@ int skb_vlan_pop(struct sk_buff *skb)
 			return err;
 	}
 	/* move next vlan tag to hw accel tag */
-	if (likely(skb->protocol != htons(ETH_P_8021Q) &&
-		   skb->protocol != htons(ETH_P_8021AD)))
+	if (likely(!eth_type_vlan(skb->protocol)))
 		return 0;
 
 	vlan_proto = skb->protocol;
-- 
2.7.4
