From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH] net: usb: smsc95xx: fix mtu
Date: Thu, 26 Apr 2012 10:02:44 +0100
Message-ID: <1335430964-1018-1-git-send-email-steve.glendinning@shawell.net>
Cc: Stephane Fillod <fillods@users.sf.net>,
	"David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:37130 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073Ab2DZJJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:09:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make smsc95xx recalculate the hard_mtu after adjusting the hard_header_len.

Without this, usbnet adjusts the MTU down to 1492 bytes, and the host is
unable to receive standard 1500-byte frames from the device.

Inspired by same fixes on cdc_eem 78fb72f7936c01d5b426c03a691eca082b03f2b9
and smsc75xx a99ff7d0123b19ecad3b589480b6542716ab6b52.

Tested on i386 with EVB-LAN9500-LC.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 5f19f84..53a1ba5 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1017,6 +1017,7 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->ethtool_ops = &smsc95xx_ethtool_ops;
 	dev->net->flags |= IFF_MULTICAST;
 	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD_CSUM;
+	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
 	return 0;
 }
 
-- 
1.7.5.4
