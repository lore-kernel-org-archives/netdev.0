From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: [PATCH 3/5] new pcmcia IDs for hostap - D-Link DCF-660W
Date: Fri, 12 May 2006 15:45:18 +0200
Message-ID: <200605121545.19635.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:55264 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S932068AbWELNpX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 09:45:23 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I use D-Link DCF-660W card with WPA protected network. By default
orinoco_cs was loaded for my card so I was not able to connect. This patch
make my card working with hostap_cs (like it was when I used pcmcia-cs).
Card was used with hostap_cs during last year in two Zaurus models (2.4.18
on one and 2.6.11 - 2.6.16 on another).

I do not know does removing card from orinoco_cs is correct way.

Platform: Sharp Zaurus C760 running 2.6.16 and pcmciautils 013.

root@c7x0:~# pccardctl ident
Socket 0:
  product info: "D-Link", "DCF-660W", "", ""
  manfid: 0xd601, 0x0005
  function: 6 (network)

root@c7x0:~# iwconfig wlan0
wlan0     IEEE 802.11b  ESSID:"test"
          Mode:Master  Frequency:2.422 GHz  Access Point: 00:80:C8:2C:09:3F
          Bit Rate:11 Mb/s   Sensitivity=1/3
          Retry min limit:8   RTS thr:off   Fragment thr:off
          Encryption key:off
          Power Management:off
          Link Quality:0  Signal level:0  Noise level:0
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:0  Invalid misc:0   Missed beacon:0

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:36:08.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:43:36.000000000 +0200
@@ -974,6 +974,8 @@
 		0x273fe3db, 0x32a1eaee),
 	PCMCIA_DEVICE_PROD_ID12("Linksys", "Wireless CompactFlash Card",
 				0x0733cc81, 0x0c52f395),
+ 	PCMCIA_DEVICE_PROD_ID12("D-Link", "DCF-660W",
+				0x1a424a1c, 0xe78b6dcc),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);
Index: linux/drivers/net/wireless/orinoco_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/orinoco_cs.c	2006-05-12 15:34:49.000000000 +0200
+++ linux/drivers/net/wireless/orinoco_cs.c	2006-05-12 15:42:32.000000000 +0200
@@ -539,7 +539,6 @@
 	PCMCIA_DEVICE_MANF_CARD(0xc001, 0x0008), /* CONTEC FLEXSCAN/FX-DDS110-PCC */
 	PCMCIA_DEVICE_MANF_CARD(0xc250, 0x0002), /* Conceptronic CON11Cpro, EMTAC A2424i */
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0002), /* Safeway 802.11b, ZCOMAX AirRunner/XI-300 */
-	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0005), /* D-Link DCF660, Sandisk Connect SDWCFB-000 */
 	PCMCIA_DEVICE_PROD_ID12(" ", "IEEE 802.11 Wireless LAN/PC Card", 0x3b6e20c8, 0xefccafe9),
 	PCMCIA_DEVICE_PROD_ID12("3Com", "3CRWE737A AirConnect Wireless LAN PC Card", 0x41240e5b, 0x56010af3),
 	PCMCIA_DEVICE_PROD_ID12("ACTIONTEC", "PRISM Wireless LAN PC Card", 0x393089da, 0xa71e69d5),

-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

   Fear leads to anger, anger leads to hate, hate... leads to suffering.
   		-- Yoda
