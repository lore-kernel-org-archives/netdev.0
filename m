From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: [PATCH] usbnet: make usbnet_get_link() fall back to ethtool_op_get_link()
Date: Thu, 26 Feb 2009 18:19:18 +0100
Message-ID: <87y6vti0a1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:59701 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804AbZBZRTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 12:19:31 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1LcjtQ-0001q4-P6
	for netdev@vger.kernel.org; Thu, 26 Feb 2009 17:19:28 +0000
Received: from nemi.mork.no ([148.122.252.4])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 17:19:28 +0000
Received: from bjorn by nemi.mork.no with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 17:19:28 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make usbnet_get_link() fall back to ethtool_op_get_link() instead of
defaulting to 1. =20
    =20
This makes usbnet_get_link return valid results without the need for a
driver specific check_connect or mii ops as long as the driver calls
netif_carrier_{on,off}() as appropriate.  cdc_ether is an example of
such a driver.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index aa31490..c32284f 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -723,8 +723,8 @@ u32 usbnet_get_link (struct net_device *net)
 	if (dev->mii.mdio_read)
 		return mii_link_ok(&dev->mii);
=20
-	/* Otherwise, say we're up (to avoid breaking scripts) */
-	return 1;
+	/* Otherwise, dtrt for drivers calling netif_carrier_{on,off} */
+	return ethtool_op_get_link(net);
 }
 EXPORT_SYMBOL_GPL(usbnet_get_link);
=20


