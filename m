From: Petr Kulhavy <brain@jikos.cz>
Subject: [PATCH] smsc95xx: use ethtool_op_get_ts_info()
Date: Thu, 13 Jul 2017 19:40:57 +0200
Message-ID: <1499967657-16849-1-git-send-email-brain@jikos.cz>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        Petr Kulhavy <brain@jikos.cz>
To: steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vie01a-dmta-ch02-2.mx.upcmail.net ([84.116.36.95]:31805 "EHLO
        vie01a-dmta-ch02-2.mx.upcmail.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751017AbdGMRle (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 13:41:34 -0400
Received: from [172.31.216.43] (helo=vie01a-pemc-psmtp-pe01)
        by vie01a-dmta-ch02.mx.upcmail.net with esmtp (Exim 4.88)
        (envelope-from <brain@jikos.cz>)
        id 1dVi7I-0005R8-Er
        for netdev@vger.kernel.org; Thu, 13 Jul 2017 19:41:32 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change enables the use of SW timestamping on Raspberry PI.

smsc95xx uses the usbnet transmit function usbnet_start_xmit(), which
implements software timestamping. However the SOF_TIMESTAMPING_TX_SOFTWARE
capability was missing and only SOF_TIMESTAMPING_RX_SOFTWARE was announced.
By using ethtool_op_get_ts_info() as get_ts_info() also the
SOF_TIMESTAMPING_TX_SOFTWARE is announced.

Signed-off-by: Petr Kulhavy <brain@jikos.cz>
---
 drivers/net/usb/smsc95xx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 2dfca96..340c134 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -898,6 +898,7 @@ static const struct ethtool_ops smsc95xx_ethtool_ops = {
 	.set_wol	= smsc95xx_ethtool_set_wol,
 	.get_link_ksettings	= smsc95xx_get_link_ksettings,
 	.set_link_ksettings	= smsc95xx_set_link_ksettings,
+	.get_ts_info	= ethtool_op_get_ts_info,
 };
 
 static int smsc95xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
-- 
2.7.4
