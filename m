From: Joe Perches <joe@perches.com>
Subject: [PATCH] 2.6.0-test5-bk11 PKT_CAN_SHARE_SKB [2/3] drivers/net/*
Date: Wed, 24 Sep 2003 15:33:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064442811.15437.26.camel@localhost.localdomain>
References: <Pine.LNX.4.44.0309241012110.3178-100000@home.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0309241012110.3178-100000@home.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -urN linux-2.6.0-test5/drivers/net/bonding/bond_alb.c shared_skb/drivers/net/bonding/bond_alb.c
-- linux-2.6.0-test5/drivers/net/bonding/bond_alb.c	2003-09-22 08:03:41.000000000 -0700
+++ shared_skb/drivers/net/bonding/bond_alb.c	2003-09-22 13:10:57.000000000 -0700
@@ -888,7 +888,7 @@
 	pk_type->type = __constant_htons(ETH_P_ARP);
 	pk_type->dev = bond->device;
 	pk_type->func = rlb_arp_recv;
-	pk_type->data = (void*)1;  /* understand shared skbs */
+	pk_type->data = PKT_CAN_SHARE_SKB;
 
 	dev_add_pack(pk_type);
 
diff -urN linux-2.6.0-test5/drivers/net/bonding/bond_main.c shared_skb/drivers/net/bonding/bond_main.c
-- linux-2.6.0-test5/drivers/net/bonding/bond_main.c	2003-09-22 08:03:41.000000000 -0700
+++ shared_skb/drivers/net/bonding/bond_main.c	2003-09-22 13:10:55.000000000 -0700
@@ -955,7 +955,7 @@
 	pk_type->type = PKT_TYPE_LACPDU;
 	pk_type->dev = bond->device;
 	pk_type->func = bond_3ad_lacpdu_recv;
-	pk_type->data = (void*)1;  /* understand shared skbs */
+	pk_type->data = PKT_CAN_SHARE_SKB;
 
 	dev_add_pack(pk_type);
 }
diff -urN linux-2.6.0-test5/drivers/net/pppoe.c shared_skb/drivers/net/pppoe.c
-- linux-2.6.0-test5/drivers/net/pppoe.c	2003-09-22 08:03:43.000000000 -0700
+++ shared_skb/drivers/net/pppoe.c	2003-09-22 13:10:52.000000000 -0700
@@ -468,13 +468,13 @@
 static struct packet_type pppoes_ptype = {
 	.type	= __constant_htons(ETH_P_PPP_SES),
 	.func	= pppoe_rcv,
-	.data   = (void *)1,
+	.data   = PKT_CAN_SHARE_SKB,
 };
 
 static struct packet_type pppoed_ptype = {
 	.type	= __constant_htons(ETH_P_PPP_DISC),
 	.func	= pppoe_disc_rcv,
-	.data   = (void *)1,
+	.data   = PKT_CAN_SHARE_SKB,
 };
 
 /***********************************************************************
diff -urN linux-2.6.0-test5/drivers/net/wan/hdlc_generic.c shared_skb/drivers/net/wan/hdlc_generic.c
-- linux-2.6.0-test5/drivers/net/wan/hdlc_generic.c	2003-09-08 12:49:53.000000000 -0700
+++ shared_skb/drivers/net/wan/hdlc_generic.c	2003-09-22 13:11:02.000000000 -0700
@@ -283,7 +283,7 @@
 {
 	.type = __constant_htons(ETH_P_HDLC),
 	.func = hdlc_rcv,
-	.data = (void *)1,
+	.data = PKT_CAN_SHARE_SKB,
 };
 

diff -urN linux-2.6.0-test5/drivers/net/wan/syncppp.c shared_skb/drivers/net/wan/syncppp.c
-- linux-2.6.0-test5/drivers/net/wan/syncppp.c	2003-09-08 12:49:58.000000000 -0700
+++ shared_skb/drivers/net/wan/syncppp.c	2003-09-22 13:11:00.000000000 -0700
@@ -1454,7 +1454,7 @@
 struct packet_type sppp_packet_type = {
 	.type	= __constant_htons(ETH_P_WAN_PPP),
 	.func	= sppp_rcv,
-	.data   = (void*)1, /* must be non-NULL to indicate 'new' protocol */
+	.data   = PKT_CAN_SHARE_SKB,
 };
 
 static char banner[] __initdata = 
