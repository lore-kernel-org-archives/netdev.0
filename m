From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 10/17] batman-adv: Count all non-success TX packets as dropped
Date: Tue,  8 Nov 2016 17:45:19 +0100
Message-ID: <20161108164526.7518-11-sw@simonwunderlich.de>
References: <20161108164526.7518-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:48900 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753929AbcKHQqA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 11:46:00 -0500
In-Reply-To: <20161108164526.7518-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

A failure during the submission also causes dropped packets.
batadv_interface_tx should therefore also increase the DROPPED counter for
these returns.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/soft-interface.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 2f0304e..7b3494a 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -386,7 +386,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 			ret = batadv_send_skb_via_tt(bat_priv, skb, dst_hint,
 						     vid);
 		}
-		if (ret == NET_XMIT_DROP)
+		if (ret != NET_XMIT_SUCCESS)
 			goto dropped_freed;
 	}
 
-- 
2.10.1
