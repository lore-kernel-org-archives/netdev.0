From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [patch] 2.[46]: Set ARP hw type correctly for BOOTP over FDDI
Date: Thu, 12 Aug 2004 14:06:13 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58L.0408121209020.6600@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

 Using the Ethernet ARP hw type for FDDI networks is mandated by RFC 1390
(STD 36) and that code is already used by Linux elsewhere, but not for
BOOTP requests sent for IPv4 autoconfiguration.  Here is a patch for both
2.4 and 2.6 that fixes the problem for me.  Please apply.

  Maciej

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

patch-ipconfig-fddi-0
diff -up --recursive --new-file linux.macro/net/ipv4/ipconfig.c linux/net/ipv4/ipconfig.c
--- linux.macro/net/ipv4/ipconfig.c	2003-11-17 04:00:34.000000000 +0000
+++ linux/net/ipv4/ipconfig.c	2004-08-12 00:03:32.000000000 +0000
@@ -689,6 +689,8 @@ static void __init ic_bootp_send_if(stru
 		b->htype = dev->type;
 	else if (dev->type == ARPHRD_IEEE802_TR) /* fix for token ring */
 		b->htype = ARPHRD_IEEE802;
+	else if (dev->type == ARPHRD_FDDI)
+		b->htype = ARPHRD_ETHER;
 	else {
 		printk("Unknown ARP type 0x%04x for device %s\n", dev->type, dev->name);
 		b->htype = dev->type; /* can cause undefined behavior */
