From: Stephane Fillod <fillods@users.sf.net>
Subject: [PATCH] net: usb: smsc75xx: fix mtu
Date: Sun, 15 Apr 2012 23:38:29 +0200
Message-ID: <20120415213829.GI5277@charybde.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steve.glendinning@smsc.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.services.sfr.fr ([93.17.128.21]:35614 "EHLO
	smtp23.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773Ab2DOVry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 17:47:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make smsc75xx recalculate the hard_mtu after adjusting the
hard_header_len.

Without this, usbnet adjusts the MTU down to 1492 bytes, and the host is
unable to receive standard 1500-byte frames from the device.

Inspired by same fix on cdc_eem 78fb72f7936c01d5b426c03a691eca082b03f2b9.

Tested on ARM/Omap3 with EVB-LAN7500-LC.

Signed-off-by: Stephane Fillod <fillods@users.sf.net>
---

--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1049,6 +1049,7 @@
 	dev->net->ethtool_ops = &smsc75xx_ethtool_ops;
 	dev->net->flags |= IFF_MULTICAST;
 	dev->net->hard_header_len += SMSC75XX_TX_OVERHEAD;
+	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
 	return 0;
 }
 
