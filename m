From: "Simon Barber" <simon@instant802.com>
Subject: [PATCH 2.4.26-pre1] Allow ebtables module to change protocol in netif_receive_skb
Date: Wed, 25 Feb 2004 14:47:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <AC8C1F46CD753F4AAC8F890E35A9EB461C670B@webmail.instant802.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Bart De Schuymer" <bdschuym@pandora.be>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Kernel Mailing List" <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Currently skb->protocol is read before the bridge is called, even though
it's not used until after. Hence if an ebtables module changes the
protocol of a frame the wrong protocol is interpreted.

Simon Barber

--- linux-2.4.26-pre1.orig/net/core/dev.c	2004-02-25
04:16:33.000000000 -0800
+++ linux-2.4.26-pre1/net/core/dev.c	2004-02-25 06:42:05.000000000
-0800
@@ -1462,7 +1462,7 @@
 {
 	struct packet_type *ptype, *pt_prev;
 	int ret = NET_RX_DROP;
-	unsigned short type = skb->protocol;
+	unsigned short type;
 
 	if (skb->stamp.tv_sec == 0)
 		do_gettimeofday(&skb->stamp);
@@ -1507,6 +1507,7 @@
 	}
 #endif
 
+	type = skb->protocol;
 	for (ptype=ptype_base[ntohs(type)&15];ptype;ptype=ptype->next) {
 		if (ptype->type == type &&
 		    (!ptype->dev || ptype->dev == skb->dev)) {
