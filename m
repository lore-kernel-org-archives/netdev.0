From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: [PATCH 2/5] new pcmcia IDs for hostap - Linksys WCF12
Date: Fri, 12 May 2006 15:40:58 +0200
Message-ID: <200605121540.59378.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:16021 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S932065AbWELNlI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 09:41:08 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Not sure about removing this card from orinoco driver and should I add
PCMCIA_DEVICE_MANF_CARD or does PCMCIA_DEVICE_PROD_ID* is enough.

-----------------------------------------------------------------------

Here's another card that would benefit from a hostap driver:

Platform: Sharp Zaurus SL-C3100 running 2.6.16 + pcmciautils 013

root@spitz:~# pccardctl ident
Socket 0:
  product info: "HITACHI", "microdrive", "", ""
  manfid: 0x0319, 0x0000
  function: 4 (fixed disk)
Socket 1:
  product info: "Linksys", "Wireless CompactFlash Card", "", ""
  manfid: 0x028a, 0x0673
  function: 6 (network)

root@spitz:~# ifconfig wlan0
wlan0     Link encap:Ethernet  HWaddr 00:0C:41:15:BB:0F  
          inet addr:192.168.0.225  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:41ff:fe15:bb0f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:242 errors:0 dropped:0 overruns:0 frame:0
          TX packets:151 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:22627 (22.0 KiB)  TX bytes:28096 (27.4 KiB)
          Interrupt:137

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:34:25.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:34:59.000000000 +0200
@@ -884,6 +884,7 @@
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1612),
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1613),
 	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0002),
+	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0673), /* Linksys WCF12 Wireless CompactFlash Card */
 	PCMCIA_DEVICE_MANF_CARD(0x02aa, 0x0002),
 	PCMCIA_DEVICE_MANF_CARD(0x02d2, 0x0001),
 	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x0001),
@@ -971,6 +972,8 @@
 	PCMCIA_DEVICE_PROD_ID12(
 		"ZoomAir 11Mbps High", "Rate wireless Networking",
 		0x273fe3db, 0x32a1eaee),
+	PCMCIA_DEVICE_PROD_ID12("Linksys", "Wireless CompactFlash Card",
+				0x0733cc81, 0x0c52f395),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);
Index: linux/drivers/net/wireless/orinoco_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/orinoco_cs.c	2006-05-12 15:03:31.000000000 +0200
+++ linux/drivers/net/wireless/orinoco_cs.c	2006-05-12 15:34:49.000000000 +0200
@@ -532,7 +532,6 @@
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1612), /* Linksys WPC11 Version 2.5 */
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1613), /* Linksys WPC11 Version 3 */
 	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0002), /* Compaq HNW-100 11 Mbps Wireless Adapter */
-	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0673), /* Linksys WCF12 Wireless CompactFlash Card */
 	PCMCIA_DEVICE_MANF_CARD(0x02ac, 0x0002), /* SpeedStream SS1021 Wireless Adapter */
 	PCMCIA_DEVICE_MANF_CARD(0x14ea, 0xb001), /* PLANEX RoadLannerWave GW-NS11H */
 	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x7300), /* Airvast WN-100 */
@@ -570,7 +569,6 @@
 	PCMCIA_DEVICE_PROD_ID12("Intersil", "PRISM 2_5 PCMCIA ADAPTER", 0x4b801a17, 0x6345a0bf),
 	PCMCIA_DEVICE_PROD_ID123("Intersil", "PRISM Freedom PCMCIA Adapter", "ISL37100P", 0x4b801a17, 0xf222ec2d, 0x630d52b2),
 	PCMCIA_DEVICE_PROD_ID12("LeArtery", "SYNCBYAIR 11Mbps Wireless LAN PC Card", 0x7e3b326a, 0x49893e92),
-	PCMCIA_DEVICE_PROD_ID12("Linksys", "Wireless CompactFlash Card", 0x0733cc81, 0x0c52f395),
 	PCMCIA_DEVICE_PROD_ID12("Lucent Technologies", "WaveLAN/IEEE", 0x23eb9949, 0xc562e72a),
 	PCMCIA_DEVICE_PROD_ID12("MELCO", "WLI-PCM-L11", 0x481e0094, 0x7360e410),
 	PCMCIA_DEVICE_PROD_ID12("MELCO", "WLI-PCM-L11G", 0x481e0094, 0xf57ca4b3),



-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

         Real programmers don't document.
         If it was hard to write, it should be hard to understand.
