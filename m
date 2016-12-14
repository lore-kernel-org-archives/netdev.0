From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: davicom: dm9000: use new api ethtool_{get|set}_link_ksettings
Date: Wed, 14 Dec 2016 10:01:58 +0100
Message-ID: <1481706118-13076-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, robert.jarzmik@free.fr, mugunthanvnm@ti.com,
        marcel@ziswiler.com, jarod@redhat.com, s.nawrocki@samsung.com,
        fw@strlen.de, harvey.hunt@imgtec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:33652 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754826AbcLNJCH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 04:02:07 -0500
Received: by mail-wj0-f193.google.com with SMTP id kp2so3144078wjc.0
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 01:02:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/davicom/dm9000.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index f1a81c5..008dc81 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -570,19 +570,21 @@ static void dm9000_set_msglevel(struct net_device *dev, u32 value)
 	dm->msg_enable = value;
 }
 
-static int dm9000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int dm9000_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct board_info *dm = to_dm9000_board(dev);
 
-	mii_ethtool_gset(&dm->mii, cmd);
+	mii_ethtool_get_link_ksettings(&dm->mii, cmd);
 	return 0;
 }
 
-static int dm9000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int dm9000_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct board_info *dm = to_dm9000_board(dev);
 
-	return mii_ethtool_sset(&dm->mii, cmd);
+	return mii_ethtool_set_link_ksettings(&dm->mii, cmd);
 }
 
 static int dm9000_nway_reset(struct net_device *dev)
@@ -741,8 +743,6 @@ static int dm9000_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 
 static const struct ethtool_ops dm9000_ethtool_ops = {
 	.get_drvinfo		= dm9000_get_drvinfo,
-	.get_settings		= dm9000_get_settings,
-	.set_settings		= dm9000_set_settings,
 	.get_msglevel		= dm9000_get_msglevel,
 	.set_msglevel		= dm9000_set_msglevel,
 	.nway_reset		= dm9000_nway_reset,
@@ -752,6 +752,8 @@ static int dm9000_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 	.get_eeprom_len		= dm9000_get_eeprom_len,
 	.get_eeprom		= dm9000_get_eeprom,
 	.set_eeprom		= dm9000_set_eeprom,
+	.get_link_ksettings	= dm9000_get_link_ksettings,
+	.set_link_ksettings	= dm9000_set_link_ksettings,
 };
 
 static void dm9000_show_carrier(struct board_info *db,
-- 
1.7.4.4
