From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH v3 net-next] phy: increase size of MII_BUS_ID_SIZE and bus_id
Date: Thu, 19 Jan 2017 17:05:04 +0100
Message-ID: <1484841904-19313-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        =?UTF-8?q?Magnus=20=C3=96berg?= <magnus.oberg@westermo.se>
To: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35427 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753153AbdASQFW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 11:05:22 -0500
Received: by mail-lf0-f66.google.com with SMTP id v186so5929248lfa.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 08:05:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some bus names are pretty long and do not fit into
17 chars. Increase therefore MII_BUS_ID_SIZE and
phy_fixup.bus_id to larger number. Now mii_bus.id
can host larger name.

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Signed-off-by: Magnus Öberg <magnus.oberg@westermo.se>
---
 include/linux/phy.h | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index f7d95f6..5c9d252 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -158,11 +158,7 @@ static inline const char *phy_modes(phy_interface_t interface)
 /* Used when trying to connect to a specific phy (mii bus id:phy device id) */
 #define PHY_ID_FMT "%s:%02x"
 
-/*
- * Need to be a little smaller than phydev->dev.bus_id to leave room
- * for the ":%02x"
- */
-#define MII_BUS_ID_SIZE	(20 - 3)
+#define MII_BUS_ID_SIZE	61
 
 /* Or MII_ADDR_C45 into regnum for read/write on mii_bus to enable the 21 bit
    IEEE 802.3ae clause 45 addressing mode used by 10GIGE phy chips. */
@@ -632,7 +628,7 @@ struct phy_driver {
 /* A Structure for boards to register fixups with the PHY Lib */
 struct phy_fixup {
 	struct list_head list;
-	char bus_id[20];
+	char bus_id[MII_BUS_ID_SIZE + 3];
 	u32 phy_uid;
 	u32 phy_uid_mask;
 	int (*run)(struct phy_device *phydev);
-- 
2.7.4
