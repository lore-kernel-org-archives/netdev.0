From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/31: ebtables: Use %pM conversion specifier
Date: Thu, 10 Sep 2009 18:11:49 +0200 (MEST)
Message-ID: <20090910161144.31179.33527.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit be39ee11cd1f67b51ac8e71d177a981eb34f2ab2
Author: Tobias Klauser <klto@zhaw.ch>
Date:   Mon Aug 10 10:10:55 2009 +0200

    netfilter: ebtables: Use %pM conversion specifier
    
    ebt_log uses its own implementation of print_mac to print MAC addresses.
    This patch converts it to use the %pM conversion specifier for printk.
    
    Signed-off-by: Tobias Klauser <klto@zhaw.ch>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index a94f3cc..e4ea3fd 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -50,14 +50,6 @@ struct arppayload
 	unsigned char ip_dst[4];
 };
 
-static void print_MAC(const unsigned char *p)
-{
-	int i;
-
-	for (i = 0; i < ETH_ALEN; i++, p++)
-		printk("%02x%c", *p, i == ETH_ALEN - 1 ? ' ':':');
-}
-
 static void
 print_ports(const struct sk_buff *skb, uint8_t protocol, int offset)
 {
@@ -88,14 +80,11 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 	unsigned int bitmask;
 
 	spin_lock_bh(&ebt_log_lock);
-	printk("<%c>%s IN=%s OUT=%s MAC source = ", '0' + loginfo->u.log.level,
-	       prefix, in ? in->name : "", out ? out->name : "");
-
-	print_MAC(eth_hdr(skb)->h_source);
-	printk("MAC dest = ");
-	print_MAC(eth_hdr(skb)->h_dest);
-
-	printk("proto = 0x%04x", ntohs(eth_hdr(skb)->h_proto));
+	printk("<%c>%s IN=%s OUT=%s MAC source = %pM MAC dest = %pM proto = 0x%04x",
+	       '0' + loginfo->u.log.level, prefix,
+	       in ? in->name : "", out ? out->name : "",
+	       eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
+	       ntohs(eth_hdr(skb)->h_proto));
 
 	if (loginfo->type == NF_LOG_TYPE_LOG)
 		bitmask = loginfo->u.log.logflags;
@@ -171,12 +160,8 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 				printk(" INCOMPLETE ARP payload");
 				goto out;
 			}
-			printk(" ARP MAC SRC=");
-			print_MAC(ap->mac_src);
-			printk(" ARP IP SRC=%pI4", ap->ip_src);
-			printk(" ARP MAC DST=");
-			print_MAC(ap->mac_dst);
-			printk(" ARP IP DST=%pI4", ap->ip_dst);
+			printk(" ARP MAC SRC=%pM ARP IP SRC=%pI4 ARP MAC DST=%pM ARP IP DST=%pI4",
+					ap->mac_src, ap->ip_src, ap->mac_dst, ap->ip_dst);
 		}
 	}
 out:
