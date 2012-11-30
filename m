From: Alan Ott <alan@signal11.us>
Subject: [PATCH 2/2] mac802154: use kfree_skb() instead of dev_kfree_skb()
Date: Thu, 29 Nov 2012 23:25:11 -0500
Message-ID: <1354249511-8086-2-git-send-email-alan@signal11.us>
References: <504EA95C.9010003@signal11.us>
 <1354249511-8086-1-git-send-email-alan@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:51680 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754197Ab2K3EZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 23:25:12 -0500
In-Reply-To: <1354249511-8086-1-git-send-email-alan@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree_skb() indicates failure, which is where this is being used.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 net/mac802154/tx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index db63914..4e09d07 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -99,7 +99,7 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 	}
 
 	if (skb_cow_head(skb, priv->hw.extra_tx_headroom)) {
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
-- 
1.7.11.2
