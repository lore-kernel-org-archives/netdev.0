From: Tony Cheneau <tony.cheneauh@amnesiak.org>
Subject: [PATCH net-next 2/4] 6lowpan: Incorrect type in
 lowpan_alloc_new_frame() definition : tag is u8 but should be u16
Date: Mon, 11 Jun 2012 00:39:24 -0400
Message-ID: <20120611003924.7c31e3da@dualbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com
To: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:52960 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733Ab2FKEqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 00:46:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lowpan_alloc_new_frame() takes u8 tag as an argument. Howerer,
its only caller, lowpan_process_data() passes down a u16. Hence,
the tag value got corrupted.
This prevent 6lowpan fragment reassembly after 256 fragmented packets
have been reassembled by the same recipient.
---
 net/ieee802154/6lowpan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index a52e795..af4f29b 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -654,7 +654,7 @@ static void lowpan_fragment_timer_expired(unsigned
long entry_addr) }
 
 static struct lowpan_fragment *
-lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u8 tag)
+lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u16 tag)
 {
 	struct lowpan_fragment *frame;
 
-- 
1.7.3.4
