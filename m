From: Oliver Neukum <oneukum@suse.com>
Subject: [RFC/RFT PATCH 6/9] net: usb: smsc75xx: use ksettings API
Date: Wed, 15 Mar 2017 16:02:45 +0100
Message-ID: <20170315150248.10997-7-oneukum@suse.com>
References: <20170315150248.10997-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59863 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753911AbdCOPDl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 11:03:41 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 95F55AE07
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 15:03:38 +0000 (UTC)
In-Reply-To: <20170315150248.10997-1-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes smsc75xx to use the new ksettings API of usbnet
and export the new methods to the network layer.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/smsc75xx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 0b17b40..9d9a07b 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -743,13 +743,13 @@ static const struct ethtool_ops smsc75xx_ethtool_ops = {
 	.get_drvinfo	= usbnet_get_drvinfo,
 	.get_msglevel	= usbnet_get_msglevel,
 	.set_msglevel	= usbnet_set_msglevel,
-	.get_settings	= usbnet_get_settings,
-	.set_settings	= usbnet_set_settings,
 	.get_eeprom_len	= smsc75xx_ethtool_get_eeprom_len,
 	.get_eeprom	= smsc75xx_ethtool_get_eeprom,
 	.set_eeprom	= smsc75xx_ethtool_set_eeprom,
 	.get_wol	= smsc75xx_ethtool_get_wol,
 	.set_wol	= smsc75xx_ethtool_set_wol,
+	.get_link_ksettings	= usbnet_get_ksettings,
+	.set_link_ksettings	= usbnet_set_ksettings
 };
 
 static int smsc75xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
-- 
2.10.2
