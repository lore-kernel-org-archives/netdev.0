From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/6] smsc95xx: change hard_header_len to include csum offload bytes
Date: Wed, 10 Mar 2010 18:32:34 +0000
Message-ID: <1268245959-13861-2-git-send-email-steve.glendinning@smsc.com>
References: <1268245959-13861-1-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:41122 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932694Ab0CJScm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 13:32:42 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id E8F0567E39
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 18:32:39 +0000 (GMT)
In-Reply-To: <1268245959-13861-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If tx checksum offload is enabled on this device it requires 12
bytes of headroom instead of 8.  This patch sets hard_header_len
to the larger of the two to help avoid skb_copy_expand.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index df9179a..4db0840 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1037,7 +1037,7 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->netdev_ops = &smsc95xx_netdev_ops;
 	dev->net->ethtool_ops = &smsc95xx_ethtool_ops;
 	dev->net->flags |= IFF_MULTICAST;
-	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD;
+	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD_CSUM;
 	return 0;
 }
 
-- 
1.6.6.1

