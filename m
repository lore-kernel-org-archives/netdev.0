From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: [PATCH net-next v3 2/3] 6lowpan: Change byte order when storing/accessing u16 tag
Date: Wed, 11 Jul 2012 12:51:15 -0400
Message-ID: <1342025476-20949-3-git-send-email-tony.cheneau@amnesiak.org>
References: <1342025476-20949-1-git-send-email-tony.cheneau@amnesiak.org>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:43754 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932943Ab2GKQxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 12:53:25 -0400
In-Reply-To: <1342025476-20949-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tag field should be stored and accessed using big endian byte order (as
intended in the specs). Or else, when displayed with a trafic analyser, such a
Wireshark, the field not properly displayed (e.g. 0x01 00 instead of 0x00 01,
and so on).

Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
---
 net/ieee802154/6lowpan.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 0c9f6d1..9de1ece 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -303,7 +303,7 @@ static inline int lowpan_fetch_skb_u16(struct sk_buff *skb, u16 *val)
 	if (unlikely(!pskb_may_pull(skb, 2)))
 		return -EINVAL;
 
-	*val = skb->data[0] | (skb->data[1] << 8);
+	*val = (skb->data[0] << 8) | skb->data[1];
 	skb_pull(skb, 2);
 
 	return 0;
@@ -1010,8 +1010,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb)
 	/* first fragment header */
 	head[0] = LOWPAN_DISPATCH_FRAG1 | (payload_length & 0x7);
 	head[1] = (payload_length >> 3) & 0xff;
-	head[2] = tag & 0xff;
-	head[3] = tag >> 8;
+	head[2] = tag >> 8;
+	head[3] = tag & 0xff;
 
 	err = lowpan_fragment_xmit(skb, head, header_length, 0, 0);
 
-- 
1.7.3.4
