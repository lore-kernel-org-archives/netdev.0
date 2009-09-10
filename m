From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 16/31: iptables: remove unused datalen variable
Date: Thu, 10 Sep 2009 18:12:07 +0200 (MEST)
Message-ID: <20090910161203.31179.7608.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit e5afbba1869a5d9509c61f8962be9bdebf95f7d3
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Jul 8 12:33:10 2009 +0200

    netfilter: iptables: remove unused datalen variable
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index fdefae6..3856aa3 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -315,7 +315,6 @@ ipt_do_table(struct sk_buff *skb,
 
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct iphdr *ip;
-	u_int16_t datalen;
 	bool hotdrop = false;
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
 	unsigned int verdict = NF_DROP;
@@ -328,7 +327,6 @@ ipt_do_table(struct sk_buff *skb,
 
 	/* Initialization */
 	ip = ip_hdr(skb);
-	datalen = skb->len - ip->ihl * 4;
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 	/* We handle fragments by dealing with the first fragment as
@@ -427,8 +425,6 @@ ipt_do_table(struct sk_buff *skb,
 #endif
 		/* Target might have changed stuff. */
 		ip = ip_hdr(skb);
-		datalen = skb->len - ip->ihl * 4;
-
 		if (verdict == IPT_CONTINUE)
 			e = ipt_next_entry(e);
 		else
