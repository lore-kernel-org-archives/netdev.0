From: kaber@trash.net
Subject: [PATCH 16/28] netfilter: arptables: use arp_hdr_len()
Date: Mon,  2 Aug 2010 21:57:33 +0200
Message-ID: <1280779065-9333-17-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35375 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849Ab0HBT6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:58:01 -0400
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

use arp_hdr_len().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/arp_tables.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 16c0ba0..c868dd5 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -283,16 +283,13 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	arp = arp_hdr(skb);
 	do {
 		const struct arpt_entry_target *t;
-		int hdr_len;
 
 		if (!arp_packet_match(arp, skb->dev, indev, outdev, &e->arp)) {
 			e = arpt_next_entry(e);
 			continue;
 		}
 
-		hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
-			(2 * skb->dev->addr_len);
-		ADD_COUNTER(e->counters, hdr_len, 1);
+		ADD_COUNTER(e->counters, arp_hdr_len(skb->dev), 1);
 
 		t = arpt_get_target_c(e);
 
-- 
1.7.1

