From: Oliver Neukum <oneukum@suse.com>
Subject: [RFC/RFT PATCH 7/9] net: usb: smsc95xx: use ksettings API
Date: Wed, 15 Mar 2017 16:02:46 +0100
Message-ID: <20170315150248.10997-8-oneukum@suse.com>
References: <20170315150248.10997-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59864 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753923AbdCOPDl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 11:03:41 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id BA7F9AE08
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 15:03:38 +0000 (UTC)
In-Reply-To: <20170315150248.10997-1-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides an implementation of the new ksettings API.
The methods provided by usbnet are extended.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/smsc95xx.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 831aa33..ea0d681 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -853,32 +853,32 @@ static void set_mdix_status(struct net_device *net, __u8 mdix_ctrl)
 	pdata->mdix_ctrl = mdix_ctrl;
 }
 
-static int smsc95xx_get_settings(struct net_device *net,
-				 struct ethtool_cmd *cmd)
+static int smsc95xx_get_ksettings(struct net_device *net,
+				 struct ethtool_link_ksettings *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	int retval;
 
-	retval = usbnet_get_settings(net, cmd);
+	retval = usbnet_get_ksettings(net, cmd);
 
-	cmd->eth_tp_mdix = pdata->mdix_ctrl;
-	cmd->eth_tp_mdix_ctrl = pdata->mdix_ctrl;
+	cmd->base.eth_tp_mdix = pdata->mdix_ctrl;
+	cmd->base.eth_tp_mdix_ctrl = pdata->mdix_ctrl;
 
 	return retval;
 }
 
-static int smsc95xx_set_settings(struct net_device *net,
-				 struct ethtool_cmd *cmd)
+static int smsc95xx_set_ksettings(struct net_device *net,
+				 const struct ethtool_link_ksettings *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	int retval;
 
-	if (pdata->mdix_ctrl != cmd->eth_tp_mdix_ctrl)
-		set_mdix_status(net, cmd->eth_tp_mdix_ctrl);
+	if (pdata->mdix_ctrl != cmd->base.eth_tp_mdix_ctrl)
+		set_mdix_status(net, cmd->base.eth_tp_mdix_ctrl);
 
-	retval = usbnet_set_settings(net, cmd);
+	retval = usbnet_set_ksettings(net, cmd);
 
 	return retval;
 }
@@ -889,8 +889,6 @@ static const struct ethtool_ops smsc95xx_ethtool_ops = {
 	.get_drvinfo	= usbnet_get_drvinfo,
 	.get_msglevel	= usbnet_get_msglevel,
 	.set_msglevel	= usbnet_set_msglevel,
-	.get_settings	= smsc95xx_get_settings,
-	.set_settings	= smsc95xx_set_settings,
 	.get_eeprom_len	= smsc95xx_ethtool_get_eeprom_len,
 	.get_eeprom	= smsc95xx_ethtool_get_eeprom,
 	.set_eeprom	= smsc95xx_ethtool_set_eeprom,
@@ -898,6 +896,8 @@ static const struct ethtool_ops smsc95xx_ethtool_ops = {
 	.get_regs	= smsc95xx_ethtool_getregs,
 	.get_wol	= smsc95xx_ethtool_get_wol,
 	.set_wol	= smsc95xx_ethtool_set_wol,
+	.get_link_ksettings =	smsc95xx_get_ksettings,
+	.set_link_ksettings =	smsc95xx_set_ksettings
 };
 
 static int smsc95xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
-- 
2.10.2
