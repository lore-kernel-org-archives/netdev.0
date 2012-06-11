From: Tony Cheneau <tony.cheneauh@amnesiak.org>
Subject: [PATCH net-next 3/4] 6lowpan: the two bytes of u16 tag needs to be
 stored/accessed the other way around
Date: Mon, 11 Jun 2012 00:39:53 -0400
Message-ID: <20120611003953.0725d77a@dualbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com
To: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:52961 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830Ab2FKEqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 00:46:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or else, tag values, as displayed with a trafic analyser, such a
Wireshark, are not properly displayed (e.g. 0x01 00 insted of 0x00 01,
and so on). ---
 net/ieee802154/6lowpan.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index af4f29b..af2f12e 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -307,7 +307,7 @@ static u16 lowpan_fetch_skb_u16(struct sk_buff *skb)
 
 	BUG_ON(!pskb_may_pull(skb, 2));
 
-	ret = skb->data[0] | (skb->data[1] << 8);
+	ret = (skb->data[0] << 8) | skb->data[1];
 	skb_pull(skb, 2);
 	return ret;
 }
@@ -1002,8 +1002,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb)
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
