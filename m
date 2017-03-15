From: Oliver Neukum <oneukum@suse.com>
Subject: [RFC/RFT PATCH 8/9] net: usb: asix: use ksettings API
Date: Wed, 15 Mar 2017 16:02:47 +0100
Message-ID: <20170315150248.10997-9-oneukum@suse.com>
References: <20170315150248.10997-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59865 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753915AbdCOPDl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 11:03:41 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id D4785AE09
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 15:03:38 +0000 (UTC)
In-Reply-To: <20170315150248.10997-1-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes asix to use the new ksettings API of usbnet
and export the new methods to the network layer.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/asix_devices.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 0dd5106..5997b2b 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -20,6 +20,7 @@
  */
 
 #include "asix.h"
+#include "linux/usb/usbnet.h"
 
 #define PHY_MODE_MARVELL	0x0000
 #define MII_MARVELL_LED_CTRL	0x0018
@@ -136,9 +137,9 @@ static const struct ethtool_ops ax88172_ethtool_ops = {
 	.get_eeprom_len		= asix_get_eeprom_len,
 	.get_eeprom		= asix_get_eeprom,
 	.set_eeprom		= asix_set_eeprom,
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
 	.nway_reset		= usbnet_nway_reset,
+	.get_link_ksettings	= usbnet_get_ksettings,
+	.set_link_ksettings	= usbnet_set_ksettings
 };
 
 static void ax88172_set_multicast(struct net_device *net)
@@ -301,9 +302,9 @@ static const struct ethtool_ops ax88772_ethtool_ops = {
 	.get_eeprom_len		= asix_get_eeprom_len,
 	.get_eeprom		= asix_get_eeprom,
 	.set_eeprom		= asix_set_eeprom,
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
 	.nway_reset		= usbnet_nway_reset,
+	.get_link_ksettings	= usbnet_get_ksettings,
+	.set_link_ksettings	= usbnet_set_ksettings
 };
 
 static int ax88772_link_reset(struct usbnet *dev)
@@ -775,9 +776,9 @@ static const struct ethtool_ops ax88178_ethtool_ops = {
 	.get_eeprom_len		= asix_get_eeprom_len,
 	.get_eeprom		= asix_get_eeprom,
 	.set_eeprom		= asix_set_eeprom,
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
 	.nway_reset		= usbnet_nway_reset,
+	.get_link_ksettings	= usbnet_get_ksettings,
+	.set_link_ksettings	= usbnet_set_ksettings
 };
 
 static int marvell_phy_init(struct usbnet *dev)
-- 
2.10.2
