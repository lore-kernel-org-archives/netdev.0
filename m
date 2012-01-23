From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] macvlan: fix a possible use after free
Date: Mon, 23 Jan 2012 16:38:59 +0100
Message-ID: <1327333139.2525.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:52272 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480Ab2AWPjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 10:39:03 -0500
Received: by werb13 with SMTP id b13so2204767wer.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 07:39:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit bc416d9768 (macvlan: handle fragmented multicast frames) added a
possible use after free in macvlan_handle_frame(), since
ip_check_defrag() uses pskb_may_pull() : skb header can be reallocated.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ben Greear <greearb@candelatech.com>
---
 drivers/net/macvlan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index f2f820c..9ea9921 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -173,6 +173,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
+		eth = eth_hdr(skb);
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
 			/* frame comes from an external address */
