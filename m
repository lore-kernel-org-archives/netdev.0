From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 16/17] batman-adv: Disallow zero and mcast src address for mgmt frames
Date: Tue,  8 Nov 2016 17:45:25 +0100
Message-ID: <20161108164526.7518-17-sw@simonwunderlich.de>
References: <20161108164526.7518-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:48905 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753964AbcKHQqC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 11:46:02 -0500
In-Reply-To: <20161108164526.7518-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The routing check for management frames is validating the source mac
address in the outer ethernet header. It rejects every source mac address
which is a broadcast address. But it also has to reject the zero-mac
address and multicast mac addresses.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/routing.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 9646623..381f040 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -196,8 +196,8 @@ bool batadv_check_management_packet(struct sk_buff *skb,
 	if (!is_broadcast_ether_addr(ethhdr->h_dest))
 		return false;
 
-	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
+	/* packet with invalid sender address */
+	if (!is_valid_ether_addr(ethhdr->h_source))
 		return false;
 
 	/* create a copy of the skb, if needed, to modify it. */
-- 
2.10.1
