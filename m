From: Stephane Fillod <fillods@users.sf.net>
Subject: [PATCH] net: usb: smsc95xx: fix mtu
Date: Fri, 20 Apr 2012 21:39:23 +0200
Message-ID: <20120420193923.GQ5277@charybde.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steve.glendinning@shawell.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp22.services.sfr.fr ([93.17.128.11]:12894 "EHLO
	smtp22.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308Ab2DTTj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 15:39:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make smsc95xx recalculate the hard_mtu after adjusting the
hard_header_len.

Without this, usbnet adjusts the MTU down to 1488 bytes, and the host is
unable to receive standard 1500-byte frames from the device.

Inspired by same fix on cdc_eem 78fb72f7936c01d5b426c03a691eca082b03f2b9.

Tested on ARM/Beagle.

Signed-off-by: Stephane Fillod <fillods@users.sf.net>
---

--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1016,6 +1016,7 @@
 	dev->net->ethtool_ops = &smsc95xx_ethtool_ops;
 	dev->net->flags |= IFF_MULTICAST;
 	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD_CSUM;
+	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
 	return 0;
 }
 
