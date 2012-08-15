From: JamesBetts <jimbob.betts@googlemail.com>
Subject: [PATCH 001/001] smsc95xx: Fix hard_header_len
Date: Wed, 15 Aug 2012 19:48:58 +0000
Message-ID: <1345060138-5629-1-git-send-email-jimbob.betts@googlemail.com>
Cc: steve@shawell.net, JamesBetts <jimbob.betts@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36781 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756447Ab2HOTtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 15:49:51 -0400
Received: by weyx8 with SMTP id x8so1246845wey.19
        for <netdev@vger.kernel.org>; Wed, 15 Aug 2012 12:49:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device may require up-to 12 bytes of headroom. Assign the needed_headroom
but stop lying about hard_header_len which is used in other places throughout
the kernel.

Without this patch it is not possible to use "IFB + tc filter ... action ... 
dev ifb0" as per
http://www.linuxfoundation.org/collaborate/workgroups/networking/ifb.

Tested using Raspberry Pi as a router with trafficshaping and IFB.
---
 drivers/net/usb/smsc95xx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 0aee6c0..02293dd 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1071,8 +1071,8 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->netdev_ops = &smsc95xx_netdev_ops;
 	dev->net->ethtool_ops = &smsc95xx_ethtool_ops;
 	dev->net->flags |= IFF_MULTICAST;
-	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD_CSUM;
-	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+	dev->net->needed_headroom = SMSC95XX_TX_OVERHEAD_CSUM;
+	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len + dev->net->needed_headroom;
 	return 0;
 }
 
-- 
1.7.4.1.433.gcd306
