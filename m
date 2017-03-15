From: Oliver Neukum <oneukum@suse.com>
Subject: [RFC/RFT PATCH 2/9] net: usb: cdc-ncm: use ksettings API
Date: Wed, 15 Mar 2017 16:02:41 +0100
Message-ID: <20170315150248.10997-3-oneukum@suse.com>
References: <20170315150248.10997-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59849 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753881AbdCOPDj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 11:03:39 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 1DFBEAD8F
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 15:03:38 +0000 (UTC)
In-Reply-To: <20170315150248.10997-1-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes CDC-NCM to use the new ksettings API of usbnet
and export the new methods to the network layer.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/cdc_ncm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f317984..311c7b6 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -131,8 +131,6 @@ static void cdc_ncm_get_strings(struct net_device __always_unused *netdev, u32 s
 static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, u32 new_tx);
 
 static const struct ethtool_ops cdc_ncm_ethtool_ops = {
-	.get_settings      = usbnet_get_settings,
-	.set_settings      = usbnet_set_settings,
 	.get_link          = usbnet_get_link,
 	.nway_reset        = usbnet_nway_reset,
 	.get_drvinfo       = usbnet_get_drvinfo,
@@ -142,6 +140,8 @@ static const struct ethtool_ops cdc_ncm_ethtool_ops = {
 	.get_sset_count    = cdc_ncm_get_sset_count,
 	.get_strings       = cdc_ncm_get_strings,
 	.get_ethtool_stats = cdc_ncm_get_ethtool_stats,
+	.get_link_ksettings	= usbnet_get_ksettings,
+	.set_link_ksettings	= usbnet_set_ksettings
 };
 
 static u32 cdc_ncm_check_rx_max(struct usbnet *dev, u32 new_rx)
-- 
2.10.2
