From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: Re: [PATCH 1/5] new pcmcia IDs for hostap - ASUS WL-110 (FIXED)
Date: Fri, 12 May 2006 15:37:20 +0200
Message-ID: <200605121537.21234.linux-arm@hrw.one.pl>
References: <200605121521.32410.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:1703 "EHLO smtp.host4.kei.pl")
	by vger.kernel.org with ESMTP id S1751297AbWELNh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 09:37:26 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200605121521.32410.linux-arm@hrw.one.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This time I checked more carefully my changeset and split it into
smaller parts. Few of my patches was tested by OpenZaurus users, some
are waiting for testing.

We switched to pcmciautils when moved to 2.6.16 and many users complain
that their WiFi CompactFlash cards are driven by orinoco instead of
hostap.

BTW - how to force using of hostap_cs when both hostap_cs and orinoco_cs
has card in device table?

All patches require 24_hostap_cs_id.diff from Pavel Roskin.

I'm subscribed to netdev mailing list now.
-----------------------------------------------------------------------

Here's another card that would benefit from a hostap driver: ASUS WL-110

Platform: HP Ipaq hx4700 running 2.6.16-hh

root@ipaq-pxa270:~# pccardctl ident
Socket 0:
  product info: "ASUS", "802_11B_CF_CARD_25", "Version 01.00", ""
  manfid: 0x02aa, 0x0002
  function: 6 (network)

root@ipaq-pxa270:~# ifconfig wlan0
wlan0     Link encap:Ethernet  HWaddr 00:0C:6E:F0:DA:CD
          inet addr:172.20.0.3  Bcast:172.20.255.255  Mask:255.255.0.0
          inet6 addr: 2001:610:600:93:20c:6eff:fef0:dacd/64 Scope:Global
          inet6 addr: fe80::20c:6eff:fef0:dacd/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:158 errors:0 dropped:0 overruns:0 frame:0
          TX packets:77 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:17978 (17.5 KiB)  TX bytes:11424 (11.1 KiB)
          Interrupt:92


Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

Index: linux/drivers/net/wireless/orinoco_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/orinoco_cs.c	2006-05-12 
15:02:13.000000000 +0200
+++ linux/drivers/net/wireless/orinoco_cs.c	2006-05-12 15:03:31.000000000 
+0200
@@ -533,7 +533,6 @@
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1613), /* Linksys WPC11 Version 3 */
 	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0002), /* Compaq HNW-100 11 Mbps 
Wireless Adapter */
 	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0673), /* Linksys WCF12 Wireless 
CompactFlash Card */
-	PCMCIA_DEVICE_MANF_CARD(0x02aa, 0x0002), /* ASUS SpaceLink WL-100 */
 	PCMCIA_DEVICE_MANF_CARD(0x02ac, 0x0002), /* SpeedStream SS1021 Wireless 
Adapter */
 	PCMCIA_DEVICE_MANF_CARD(0x14ea, 0xb001), /* PLANEX RoadLannerWave 
GW-NS11H */
 	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x7300), /* Airvast WN-100 */
@@ -548,8 +547,6 @@
 	PCMCIA_DEVICE_PROD_ID12("Addtron", "AWP-100 Wireless PCMCIA", 0xe6ec52ce, 
0x08649af2),
 	PCMCIA_DEVICE_PROD_ID123("AIRVAST", "IEEE 802.11b Wireless PCMCIA 
Card", "HFA3863", 0xea569531, 0x4bcb9645, 0x355cb092),
 	PCMCIA_DEVICE_PROD_ID12("Allied Telesyn", "AT-WCL452 Wireless PCMCIA 
Radio", 0x5cd01705, 0x4271660f),
-	PCMCIA_DEVICE_PROD_ID12("ASUS", "802_11b_PC_CARD_25", 0x78fc06ee, 
0xdb9aa842),
-	PCMCIA_DEVICE_PROD_ID12("ASUS", "802_11B_CF_CARD_25", 0x78fc06ee, 
0x45a50c1e),
 	PCMCIA_DEVICE_PROD_ID12("Avaya Communication", "Avaya Wireless PC Card", 
0xd8a43b78, 0x0d341169),
 	PCMCIA_DEVICE_PROD_ID12("BENQ", "AWL100 PCMCIA ADAPTER", 0x35dadc74, 
0x01f7fedb),
 	PCMCIA_DEVICE_PROD_ID12("BUFFALO", "WLI-PCM-L11G", 0x2decece3, 
0xf57ca4b3),
Index: linux/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 
15:02:51.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 
15:06:26.000000000 +0200
@@ -935,6 +935,8 @@
 	PCMCIA_DEVICE_PROD_ID123(
 		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02",
 		0xc7b8df9d, 0x1700d087, 0x4b74baa0),
+	PCMCIA_DEVICE_PROD_ID1234("ASUS", "802_11B_CF_CARD_25", "Version 
01.00", "",
+				0x78fc06ee, 0x45a50c1e, 0xa57adb8c, 0x00000000),
 	PCMCIA_DEVICE_PROD_ID12("ASUS", "802_11b_PC_CARD_25",
 				0x78fc06ee, 0xdb9aa842),
 	PCMCIA_DEVICE_PROD_ID12("ASUS", "802_11B_CF_CARD_25",



-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

  So when I die, the first thing I will see in Heaven is a hi-score list?
