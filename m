From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] arptables: use arp_hdr_len()
Date: Fri, 23 Jul 2010 11:21:13 +0800
Message-ID: <1279855273-8889-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

arptables: use arp_hdr_len()

use arp_hdr_len()

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/netfilter/arp_tables.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)
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
 
