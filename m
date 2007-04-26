From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] usb-net/pegasus: simplify carrier detection
Date: Wed, 25 Apr 2007 21:30:29 -0400
Message-ID: <1177551029.1684.2.camel@localhost.localdomain>
References: <1177424406.13684.5.camel@localhost.localdomain>
	 <462E3508.1030703@garzik.org> <20070424170429.GA13668@kroah.com>
	 <58298.85.91.128.158.1177436881.squirrel@nucleusys.com>
	 <1177446286.18030.13.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704251648050.16498@bender.nucleusys.com>
	 <1177513723.3612.0.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704251808210.16498@bender.nucleusys.com>
	 <1177516990.3612.2.camel@localhost.localdomain>
	 <462F7B9A.2090904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Petko Manolov <petkan@nucleusys.com>, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55604 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932564AbXDZB0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 21:26:42 -0400
In-Reply-To: <462F7B9A.2090904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify pegasus carrier detection; rely only on the periodic MII
polling.  Reverts pieces of c43c49bd61fdb9bb085ddafcaadb17d06f95ec43.

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/usb/net/pegasus.h	2007-04-25 21:21:00.000000000 -0400
+++ b/drivers/usb/net/pegasus.h	2007-04-25 21:21:13.000000000 -0400
@@ -11,7 +11,6 @@
 
 #define	PEGASUS_II		0x80000000
 #define	HAS_HOME_PNA		0x40000000
-#define	TRUST_LINK_STATUS	0x20000000
 
 #define	PEGASUS_MTU		1536
 #define	RX_SKBS			4
@@ -204,7 +203,7 @@
 PEGASUS_DEV( "Allied Telesyn Int. AT-USB100", VENDOR_ALLIEDTEL, 0xb100,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121,
-		DEFAULT_GPIO_RESET | PEGASUS_II | TRUST_LINK_STATUS )
+		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Billionton USB-100", VENDOR_BILLIONTON, 0x0986,
 		DEFAULT_GPIO_RESET )
 PEGASUS_DEV( "Billionton USBLP-100", VENDOR_BILLIONTON, 0x0987,
--- a/drivers/usb/net/pegasus.c	2007-04-25 21:20:32.000000000 -0400
+++ b/drivers/usb/net/pegasus.c	2007-04-25 21:22:15.000000000 -0400
@@ -848,16 +848,6 @@
 		 * d[0].NO_CARRIER kicks in only with failed TX.
 		 * ... so monitoring with MII may be safest.
 		 */
-		if (pegasus->features & TRUST_LINK_STATUS) {
-			if (d[5] & LINK_STATUS)
-				netif_carrier_on(net);
-			else
-				netif_carrier_off(net);
-		} else {
-			/* Never set carrier _on_ based on ! NO_CARRIER */
-			if (d[0] & NO_CARRIER)
-				netif_carrier_off(net);	
-		}
 
 		/* bytes 3-4 == rx_lostpkt, reg 2E/2F */
 		pegasus->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];


