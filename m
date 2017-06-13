From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 02/10] batman-adv: decrease maximum fragment size
Date: Tue, 13 Jun 2017 13:36:52 +0200
Message-ID: <20170613113700.31220-3-sw@simonwunderlich.de>
References: <20170613113700.31220-1-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Matthias Schiffer <mschiffer@universe-factory.net>,
        =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:43794 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753099AbdFMLhI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 07:37:08 -0400
In-Reply-To: <20170613113700.31220-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

With this patch the maximum fragment size is reduced from 1400 to 1280
bytes.

Fragmentation v2 correctly uses the smaller of 1400 and the interface
MTU, thus generally supporting interfaces with an MTU < 1400 bytes, too.

However, currently "Fragmentation v2" does not support re-fragmentation.
Which means that once a packet is split into two packets of 1400 + x
bytes for instance and the next hop provides an interface with an even
smaller MTU of 1280 bytes, then the larger fragment is lost.

A maximum fragment size of 1280 bytes is a safer option as this is the
minimum MTU required by IPv6, making interfaces with an MTU < 1280
rather exotic.

Regarding performance, this should have no negative impact on unicast
traffic: Having some more bytes in the smaller and some less in the
larger does not change the sum of both fragments.

Concerning TT, choosing 1280 bytes fragments might result in more TT
messages than necessary when a large network is bridged into batman-adv.
However, the TT overhead in general is marginal due to its reactive
nature, therefore such a performance impact on TT should not be
noticeable for a user.

Cc: Matthias Schiffer <mschiffer@universe-factory.net>
[linus.luessing@c0d3.blue: Added commit message]
Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index feaf60e4cbc3..2be8f1f46529 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -168,7 +168,7 @@ enum batadv_uev_type {
 /* Maximum number of fragments for one packet */
 #define BATADV_FRAG_MAX_FRAGMENTS 16
 /* Maxumim size of each fragment */
-#define BATADV_FRAG_MAX_FRAG_SIZE 1400
+#define BATADV_FRAG_MAX_FRAG_SIZE 1280
 /* Time to keep fragments while waiting for rest of the fragments */
 #define BATADV_FRAG_TIMEOUT 10000
 
-- 
2.11.0
