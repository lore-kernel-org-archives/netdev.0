From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH 3/4] MCS7830 USB-Ether: change register define
Date: Sun, 31 Jan 2010 13:58:33 +0100
Message-ID: <20100131125833.GC13435@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
	David Hollis <dhollis@davehollis.com>,
	Phil Chang <pchang23@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:60162 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397Ab0AaM6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2010 07:58:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ChangeLog:
- rename register, add comment

Signed-off-by: Andreas Mohr <andi@lisas.de>


Index: linux-2.6.33-rc4/drivers/net/usb/mcs7830.c
===================================================================
--- linux-2.6.33-rc4.orig/drivers/net/usb/mcs7830.c	2010-01-31 12:34:45.000000000 +0100
+++ linux-2.6.33-rc4/drivers/net/usb/mcs7830.c	2010-01-31 12:34:51.000000000 +0100
@@ -85,6 +85,7 @@
 	   HIF_REG_PHY_CMD2_PEND_FLAG_BIT	= 0x80,
 	   HIF_REG_PHY_CMD2_READY_FLAG_BIT	= 0x40,
 	HIF_REG_CONFIG				= 0x0e,
+	/* hmm, spec sez: "R/W", "Except bit 3" (likely TXENABLE). */
 	   HIF_REG_CONFIG_CFG			= 0x80,
 	   HIF_REG_CONFIG_SPEED100		= 0x40,
 	   HIF_REG_CONFIG_FULLDUPLEX_ENABLE	= 0x20,
@@ -94,7 +95,7 @@
 	   HIF_REG_CONFIG_ALLMULTICAST		= 0x02,
 	   HIF_REG_CONFIG_PROMISCUOUS		= 0x01,
 	HIF_REG_ETHERNET_ADDR			= 0x0f,
-	HIF_REG_22				= 0x15,
+	HIF_REG_FRAME_DROP_COUNTER		= 0x15, /* 0..ff; reset: 0 */
 	HIF_REG_PAUSE_THRESHOLD			= 0x16,
 	   HIF_REG_PAUSE_THRESHOLD_DEFAULT	= 0,
 };
@@ -334,7 +335,7 @@
 {
 	u8 dummy[2];
 	int ret;
-	ret = mcs7830_get_reg(dev, HIF_REG_22, 2, dummy);
+	ret = mcs7830_get_reg(dev, HIF_REG_FRAME_DROP_COUNTER, 2, dummy);
 	if (ret > 0)
 		return 2; /* Rev C or later */
 	return 1; /* earlier revision */

-- 
GNU/Linux. It's not the software that's free, it's you.
