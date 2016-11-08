From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 06/17] batman-adv: Remove unused skb_reset_mac_header()
Date: Tue,  8 Nov 2016 17:45:15 +0100
Message-ID: <20161108164526.7518-7-sw@simonwunderlich.de>
References: <20161108164526.7518-1-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:48895 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753937AbcKHQqA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 11:46:00 -0500
In-Reply-To: <20161108164526.7518-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Lüssing <linus.luessing@c0d3.blue>

During broadcast queueing, the skb_reset_mac_header() sets the skb
to a place invalid for a MAC header, pointing right into the
batman-adv broadcast packet. Luckily, no one seems to actually use
eth_hdr(skb) afterwards until batadv_send_skb_packet() resets the
header to a valid position again.

Therefore removing this unnecessary, weird skb_reset_mac_header()
call.

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/send.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index e1e9136..be3f6d7 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -586,8 +586,6 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	bcast_packet = (struct batadv_bcast_packet *)newskb->data;
 	bcast_packet->ttl--;
 
-	skb_reset_mac_header(newskb);
-
 	forw_packet->skb = newskb;
 
 	INIT_DELAYED_WORK(&forw_packet->delayed_work,
-- 
2.10.1
