From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 13/24 for-2.6.25] DM9000: Add ethtool control of msg_enable value
Date: Tue, 05 Feb 2008 00:02:12 +0000
Message-ID: <20080205000817.119524873@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58720 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758836AbYBEAIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:24 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-ethtool-msglevel.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the msg_enable value to be read and written by
the ethtool interface.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -383,6 +383,20 @@ static void dm9000_get_drvinfo(struct ne
 	strcpy(info->bus_info, to_platform_device(dm->dev)->name);
 }
 
+static u32 dm9000_get_msglevel(struct net_device *dev)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	return dm->msg_enable;
+}
+
+static void dm9000_set_msglevel(struct net_device *dev, u32 value)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	dm->msg_enable = value;
+}
+
 static int dm9000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	board_info_t *dm = to_dm9000_board(dev);
@@ -464,6 +478,8 @@ static const struct ethtool_ops dm9000_e
 	.get_drvinfo		= dm9000_get_drvinfo,
 	.get_settings		= dm9000_get_settings,
 	.set_settings		= dm9000_set_settings,
+	.get_msglevel		= dm9000_get_msglevel,
+	.set_msglevel		= dm9000_set_msglevel,
 	.nway_reset		= dm9000_nway_reset,
 	.get_link		= dm9000_get_link,
  	.get_eeprom_len		= dm9000_get_eeprom_len,

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
