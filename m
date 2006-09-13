From: bora.sahin@ttnet.net.tr
Subject: [PATCH 9/12] smc911x: phy_check_media reverses MAC duplex settings
Date: Wed, 13 Sep 2006 21:25:21 +0300
Message-ID: <200609132125.21578.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:51324 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751061AbWIMSfM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:35:12 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Datasheet says, page: 98 -> http://www.smsc.com/main/datasheets/9115.pdf

"MAC_CR_RCVOWN_ should be reset when the Full 
Duplex Mode bit is set" and "When MAC_CR_FDPX_ set, the MAC operates in 
Full-Duplex mode, in which it can transmit and receive simultaneously." 

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.c
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.c	2006-08-06 21:20:11.000000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-09-04 13:54:26.621458832 +0300
@@ -927,14 +923,15 @@
 		/* duplex state has changed */
 		SMC_GET_PHY_BMCR(phyaddr, bmcr);
 		SMC_GET_MAC_CR(cr);
+		cr &= ~(MAC_CR_RCVOWN_ | MAC_CR_FDPX_);
 		if (lp->mii.full_duplex) {
 			DBG(SMC_DEBUG_MISC, "%s: Configuring for full-duplex mode\n", dev->name);
 			bmcr |= BMCR_FULLDPLX;
-			cr |= MAC_CR_RCVOWN_;
+			cr |= MAC_CR_FDPX_;
 		} else {
 			DBG(SMC_DEBUG_MISC, "%s: Configuring for half-duplex mode\n", dev->name);
 			bmcr &= ~BMCR_FULLDPLX;
-			cr &= ~MAC_CR_RCVOWN_;
+			cr |= MAC_CR_RCVOWN_;
 		}
 		SMC_SET_PHY_BMCR(phyaddr, bmcr);
 		SMC_SET_MAC_CR(cr);
