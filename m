From: Marcin Juszkiewicz <openembedded@hrw.one.pl>
Subject: Re: [PATCH 2/5] new pcmcia IDs for hostap - Linksys WCF12
Date: Fri, 12 May 2006 19:05:14 +0200
Message-ID: <200605121905.15452.openembedded@hrw.one.pl>
References: <200605121540.59378.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:36531 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S1750815AbWELRFR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 13:05:17 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200605121540.59378.linux-arm@hrw.one.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dnia pi=B1tek, 12 maja 2006 15:40, Marcin Juszkiewicz napisa=B3:
> Not sure about removing this card from orinoco driver and should I ad=
d
> PCMCIA_DEVICE_MANF_CARD or does PCMCIA_DEVICE_PROD_ID* is enough.

Updated to not touch orinoco_cs driver.

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
wlan0     Link encap:Ethernet  HWaddr 00:0C:41:15:BB:0F =20
          inet addr:192.168.0.225  Bcast:192.168.0.255  Mask:255.255.25=
5.0
          inet6 addr: fe80::20c:41ff:fe15:bb0f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:242 errors:0 dropped:0 overruns:0 frame:0
          TX packets:151 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:22627 (22.0 KiB)  TX bytes:28096 (27.4 KiB)
          Interrupt:137

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:34=
:25.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:34:59.0=
00000000 +0200
@@ -884,6 +884,7 @@
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1612),
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1613),
 	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0002),
+	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0673), /* Linksys WCF12 Wireless Co=
mpactFlash Card */
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

--=20
JID: hrw-jabber.org
Palmtop: Sharp Zaurus C760
OpenEmbedded/OpenZaurus developer

        Reality is for people who cannot cope with science fiction.
