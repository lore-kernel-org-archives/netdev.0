From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [patch] dm9601: Fix receive MTU
Date: Mon, 01 Oct 2007 13:36:07 +0200
Message-ID: <87myv35aoo.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:12789 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbXJALgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 07:36:15 -0400
Received: by nf-out-0910.google.com with SMTP id g13so2890235nfb
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2007 04:36:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please apply to 2.6.23.
---
dm9601 didn't take the ethernet header into account when calculating
RX MTU, causing packets bigger than 1486 to fail.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.23-rc8/drivers/net/usb/dm9601.c
===================================================================
--- linux-2.6.23-rc8.orig/drivers/net/usb/dm9601.c
+++ linux-2.6.23-rc8/drivers/net/usb/dm9601.c
@@ -405,7 +405,7 @@
 	dev->net->ethtool_ops = &dm9601_ethtool_ops;
 	dev->net->hard_header_len += DM_TX_OVERHEAD;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
-	dev->rx_urb_size = dev->net->mtu + DM_RX_OVERHEAD;
+	dev->rx_urb_size = dev->net->mtu + ETH_HLEN + DM_RX_OVERHEAD;
 
 	dev->mii.dev = dev->net;
 	dev->mii.mdio_read = dm9601_mdio_read;

-- 
Bye, Peter Korsgaard
