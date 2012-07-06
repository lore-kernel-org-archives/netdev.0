From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: [PATCH net-next v2 2/4] Incorrect type length in lowpan_alloc_new_frame():tag is u8 but should be u16
Date: Fri,  6 Jul 2012 00:50:23 -0400
Message-ID: <1341550225-13112-3-git-send-email-tony.cheneau@amnesiak.org>
References: <1341550225-13112-1-git-send-email-tony.cheneau@amnesiak.org>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:41237 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357Ab2GFEwV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 00:52:21 -0400
In-Reply-To: <1341550225-13112-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function lowpan_alloc_new_frame() takes u8 tag as an argument. However,
its only caller, lowpan_process_data() passes down a u16. Hence,
the tag value can get corrupted. This prevent 6lowpan fragment reassembly of a
message when the fragment tag value is over 256.

---
 net/ieee802154/6lowpan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 07fa200..5884d29 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -649,7 +649,7 @@ static void lowpan_fragment_timer_expired(unsigned long entry_addr)
 }
 
 static struct lowpan_fragment *
-lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u8 tag)
+lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u16 tag)
 {
 	struct lowpan_fragment *frame;
 
-- 
1.7.3.4
