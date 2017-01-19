From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH v2 net-next] phy: increase size of bus_id and MII_BUS_ID_SIZE
Date: Thu, 19 Jan 2017 12:46:55 +0100
Message-ID: <1484826415-31631-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        =?UTF-8?q?Magnus=20=C3=96berg?= <magnus.oberg@westermo.se>
To: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35413 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752194AbdASLrG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 06:47:06 -0500
Received: by mail-lf0-f66.google.com with SMTP id v186so5082173lfa.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 03:47:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some bus names are pretty long and do not fit into
20 chars, therefore bus_id size is increased together
with MII_BUS_ID_SIZE to host larger names.

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Signed-off-by: Magnus Öberg <magnus.oberg@westermo.se>
---
 include/linux/phy.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index f7d95f6..f53f0cd 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -162,7 +162,7 @@ static inline const char *phy_modes(phy_interface_t interface)
  * Need to be a little smaller than phydev->dev.bus_id to leave room
  * for the ":%02x"
  */
-#define MII_BUS_ID_SIZE	(20 - 3)
+#define MII_BUS_ID_SIZE	(64 - 3)
 
 /* Or MII_ADDR_C45 into regnum for read/write on mii_bus to enable the 21 bit
    IEEE 802.3ae clause 45 addressing mode used by 10GIGE phy chips. */
@@ -632,7 +632,7 @@ struct phy_driver {
 /* A Structure for boards to register fixups with the PHY Lib */
 struct phy_fixup {
 	struct list_head list;
-	char bus_id[20];
+	char bus_id[64];
 	u32 phy_uid;
 	u32 phy_uid_mask;
 	int (*run)(struct phy_device *phydev);
-- 
2.7.4
