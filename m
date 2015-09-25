From: Bastian Stender <bst@pengutronix.de>
Subject: [PATCH] net ipv4 ipconfig: use preferred log methods
Date: Fri, 25 Sep 2015 11:58:30 +0200
Message-ID: <1443175110-23498-1-git-send-email-bst@pengutronix.de>
Cc: netdev@vger.kernel.org, trivial@kernel.org, kernel@pengutronix.de,
	Bastian Stender <bst@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:52551 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030AbbIYJ6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 05:58:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace printk calls with preferred log method calls to keep kernel
messages clean.

Signed-off-by: Bastian Stender <bst@pengutronix.de>
---
 net/ipv4/ipconfig.c | 32 +++++++++++++++++---------------
 1 file changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ed4ef09..60882de 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -69,7 +69,7 @@
 #undef IPCONFIG_DEBUG
 
 #ifdef IPCONFIG_DEBUG
-#define DBG(x) printk x
+#define DBG(x) pr_debug(x)
 #else
 #define DBG(x) do { } while(0)
 #endif
@@ -460,7 +460,8 @@ static int __init ic_defaults(void)
 			       &ic_myaddr);
 			return -1;
 		}
-		printk("IP-Config: Guessing netmask %pI4\n", &ic_netmask);
+		pr_notice("IP-Config: Guessing netmask %pI4\n",
+			  &ic_netmask);
 	}
 
 	return 0;
@@ -672,7 +673,7 @@ ic_dhcp_init_options(u8 *options)
 	int len;
 
 #ifdef IPCONFIG_DEBUG
-	printk("DHCP: Sending message type %d\n", mt);
+	pr_debug("DHCP: Sending message type %d\n", mt);
 #endif
 
 	memcpy(e, ic_bootp_cookie, 4);	/* RFC1048 Magic Cookie */
@@ -833,7 +834,8 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	else if (dev->type == ARPHRD_FDDI)
 		b->htype = ARPHRD_ETHER;
 	else {
-		printk("Unknown ARP type 0x%04x for device %s\n", dev->type, dev->name);
+		pr_warn("Unknown ARP type 0x%04x for device %s\n", dev->type,
+			dev->name);
 		b->htype = dev->type; /* can cause undefined behavior */
 	}
 
@@ -857,12 +859,12 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	if (dev_hard_header(skb, dev, ntohs(skb->protocol),
 			    dev->broadcast, dev->dev_addr, skb->len) < 0) {
 		kfree_skb(skb);
-		printk("E");
+		pr_alert("E");
 		return;
 	}
 
 	if (dev_queue_xmit(skb) < 0)
-		printk("E");
+		pr_alert("E");
 }
 
 
@@ -893,10 +895,10 @@ static void __init ic_do_bootp_ext(u8 *ext)
 #ifdef IPCONFIG_DEBUG
 	u8 *c;
 
-	printk("DHCP/BOOTP: Got extension %d:",*ext);
+	pr_debug("DHCP/BOOTP: Got extension %d:", *ext);
 	for (c=ext+2; c<ext+2+ext[1]; c++)
-		printk(" %02x", *c);
-	printk("\n");
+		pr_debug(" %02x", *c);
+	pr_debug("\n");
 #endif
 
 	switch (*ext++) {
@@ -1067,7 +1069,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 			}
 
 #ifdef IPCONFIG_DEBUG
-			printk("DHCP: Got message type %d\n", mt);
+			pr_debug("DHCP: Got message type %d\n", mt);
 #endif
 
 			switch (mt) {
@@ -1082,8 +1084,8 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 				ic_myaddr = b->your_ip;
 				ic_servaddr = server_id;
 #ifdef IPCONFIG_DEBUG
-				printk("DHCP: Offered address %pI4 by server %pI4\n",
-				       &ic_myaddr, &b->iph.saddr);
+				pr_debug("DHCP: Offered address %pI4 by server %pI4\n",
+					 &ic_myaddr, &b->iph.saddr);
 #endif
 				/* The DHCP indicated server address takes
 				 * precedence over the bootp header one if
@@ -1281,10 +1283,10 @@ static int __init ic_dynamic(void)
 		return -1;
 	}
 
-	printk("IP-Config: Got %s answer from %pI4, ",
+	pr_info("IP-Config: Got %s answer from %pI4, ",
 		((ic_got_reply & IC_RARP) ? "RARP"
-		 : (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
-	       &ic_addrservaddr);
+		: (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
+		&ic_addrservaddr);
 	pr_cont("my address is %pI4\n", &ic_myaddr);
 
 	return 0;
-- 
2.1.4
