From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/22] netfilter: Use pr_cont where appropriate
Date: Mon, 20 Mar 2017 11:08:32 +0100
Message-ID: <1490004530-9128-5-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52112 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754019AbdCTKJk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:40 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id EBE19523E9
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:08 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DB191DA7F7
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:08 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4C810DA86E
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:03 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Logging output was changed when simple printks without KERN_CONT
are now emitted on a new line and KERN_CONT is required to continue
lines so use pr_cont.

Miscellanea:

o realign arguments
o use print_hex_dump instead of a local variant

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_log.c         | 34 +++++++++++++++++-----------------
 net/ipv4/netfilter/nf_nat_snmp_basic.c | 15 ++-------------
 2 files changed, 19 insertions(+), 30 deletions(-)

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 98b9c8e8615e..707caea39743 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -62,10 +62,10 @@ print_ports(const struct sk_buff *skb, uint8_t protocol, int offset)
 		pptr = skb_header_pointer(skb, offset,
 					  sizeof(_ports), &_ports);
 		if (pptr == NULL) {
-			printk(" INCOMPLETE TCP/UDP header");
+			pr_cont(" INCOMPLETE TCP/UDP header");
 			return;
 		}
-		printk(" SPT=%u DPT=%u", ntohs(pptr->src), ntohs(pptr->dst));
+		pr_cont(" SPT=%u DPT=%u", ntohs(pptr->src), ntohs(pptr->dst));
 	}
 }
 
@@ -100,11 +100,11 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 
 		ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
 		if (ih == NULL) {
-			printk(" INCOMPLETE IP header");
+			pr_cont(" INCOMPLETE IP header");
 			goto out;
 		}
-		printk(" IP SRC=%pI4 IP DST=%pI4, IP tos=0x%02X, IP proto=%d",
-		       &ih->saddr, &ih->daddr, ih->tos, ih->protocol);
+		pr_cont(" IP SRC=%pI4 IP DST=%pI4, IP tos=0x%02X, IP proto=%d",
+			&ih->saddr, &ih->daddr, ih->tos, ih->protocol);
 		print_ports(skb, ih->protocol, ih->ihl*4);
 		goto out;
 	}
@@ -120,11 +120,11 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 
 		ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
 		if (ih == NULL) {
-			printk(" INCOMPLETE IPv6 header");
+			pr_cont(" INCOMPLETE IPv6 header");
 			goto out;
 		}
-		printk(" IPv6 SRC=%pI6 IPv6 DST=%pI6, IPv6 priority=0x%01X, Next Header=%d",
-		       &ih->saddr, &ih->daddr, ih->priority, ih->nexthdr);
+		pr_cont(" IPv6 SRC=%pI6 IPv6 DST=%pI6, IPv6 priority=0x%01X, Next Header=%d",
+			&ih->saddr, &ih->daddr, ih->priority, ih->nexthdr);
 		nexthdr = ih->nexthdr;
 		offset_ph = ipv6_skip_exthdr(skb, sizeof(_iph), &nexthdr, &frag_off);
 		if (offset_ph == -1)
@@ -142,12 +142,12 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 
 		ah = skb_header_pointer(skb, 0, sizeof(_arph), &_arph);
 		if (ah == NULL) {
-			printk(" INCOMPLETE ARP header");
+			pr_cont(" INCOMPLETE ARP header");
 			goto out;
 		}
-		printk(" ARP HTYPE=%d, PTYPE=0x%04x, OPCODE=%d",
-		       ntohs(ah->ar_hrd), ntohs(ah->ar_pro),
-		       ntohs(ah->ar_op));
+		pr_cont(" ARP HTYPE=%d, PTYPE=0x%04x, OPCODE=%d",
+			ntohs(ah->ar_hrd), ntohs(ah->ar_pro),
+			ntohs(ah->ar_op));
 
 		/* If it's for Ethernet and the lengths are OK,
 		 * then log the ARP payload
@@ -161,17 +161,17 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 			ap = skb_header_pointer(skb, sizeof(_arph),
 						sizeof(_arpp), &_arpp);
 			if (ap == NULL) {
-				printk(" INCOMPLETE ARP payload");
+				pr_cont(" INCOMPLETE ARP payload");
 				goto out;
 			}
-			printk(" ARP MAC SRC=%pM ARP IP SRC=%pI4 ARP MAC DST=%pM ARP IP DST=%pI4",
-					ap->mac_src, ap->ip_src, ap->mac_dst, ap->ip_dst);
+			pr_cont(" ARP MAC SRC=%pM ARP IP SRC=%pI4 ARP MAC DST=%pM ARP IP DST=%pI4",
+				ap->mac_src, ap->ip_src,
+				ap->mac_dst, ap->ip_dst);
 		}
 	}
 out:
-	printk("\n");
+	pr_cont("\n");
 	spin_unlock_bh(&ebt_log_lock);
-
 }
 
 static unsigned int
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index c9b52c361da2..ef49989c93b1 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -998,18 +998,6 @@ static unsigned char snmp_trap_decode(struct asn1_ctx *ctx,
  *
  *****************************************************************************/
 
-static void hex_dump(const unsigned char *buf, size_t len)
-{
-	size_t i;
-
-	for (i = 0; i < len; i++) {
-		if (i && !(i % 16))
-			printk("\n");
-		printk("%02x ", *(buf + i));
-	}
-	printk("\n");
-}
-
 /*
  * Parse and mangle SNMP message according to mapping.
  * (And this is the fucking 'basic' method).
@@ -1026,7 +1014,8 @@ static int snmp_parse_mangle(unsigned char *msg,
 	struct snmp_object *obj;
 
 	if (debug > 1)
-		hex_dump(msg, len);
+		print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_NONE, 16, 1,
+			       msg, len, 0);
 
 	asn1_open(&ctx, msg, len);
 
-- 
2.1.4
