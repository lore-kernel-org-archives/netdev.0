From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 7/7] batman-adv: Treat NET_XMIT_CN as transmit successfully
Date: Thu, 26 Jan 2017 17:44:04 +0100
Message-ID: <20170126164404.16074-8-sw@simonwunderlich.de>
References: <20170126164404.16074-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Gao Feng <gfree.wind@gmail.com>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:54090 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752843AbdAZQoR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 11:44:17 -0500
In-Reply-To: <20170126164404.16074-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@gmail.com>

The tc could return NET_XMIT_CN as one congestion notification, but
it does not mean the packet is lost. Other modules like ipvlan,
macvlan, and others treat NET_XMIT_CN as success too.

So batman-adv should handle NET_XMIT_CN also as NET_XMIT_SUCCESS.

Signed-off-by: Gao Feng <gfree.wind@gmail.com>
[sven@narfation.org: Moved NET_XMIT_CN handling to batadv_send_skb_packet]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/send.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index d7308263b8fa..d9b2889064a6 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -115,7 +115,7 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 	 * congestion and traffic shaping, it drops and returns NET_XMIT_DROP
 	 * (which is > 0). This will not be treated as an error.
 	 */
-	return dev_queue_xmit(skb);
+	return net_xmit_eval(dev_queue_xmit(skb));
 send_skb_err:
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
-- 
2.11.0
