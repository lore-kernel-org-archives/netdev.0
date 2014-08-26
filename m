From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/4] net: phy: bcm7xxx: add BCM7250 and BCM7364 PHY entries
Date: Tue, 26 Aug 2014 13:15:27 -0700
Message-ID: <1409084127-30387-5-git-send-email-f.fainelli@gmail.com>
References: <1409084127-30387-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:55750 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754609AbaHZUQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 16:16:05 -0400
Received: by mail-pd0-f173.google.com with SMTP id w10so23224201pde.32
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 13:16:04 -0700 (PDT)
In-Reply-To: <1409084127-30387-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two new entries to the Broadcom BCM7xxx internal PHY driver for
BCM7250 and BCM7364 chips. Those chips share the usual 28nm process
Gigabit PHY sequence and require the same workarounds so far.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 4 ++++
 include/linux/brcmphy.h   | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 948c7086679a..09dd6e1dc6e1 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -335,6 +335,8 @@ static int bcm7xxx_dummy_config_init(struct phy_device *phydev)
 }
 
 static struct phy_driver bcm7xxx_driver[] = {
+	BCM7XXX_28NM_GPHY(PHY_ID_BCM7250, "Broadcom BCM7250"),
+	BCM7XXX_28NM_GPHY(PHY_ID_BCM7364, "Broadcom BCM7364"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7366, "Broadcom BCM7366"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439, "Broadcom BCM7439"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7445, "Broadcom BCM7445"),
@@ -367,6 +369,8 @@ static struct phy_driver bcm7xxx_driver[] = {
 } };
 
 static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
+	{ PHY_ID_BCM7250, 0xfffffff0, },
+	{ PHY_ID_BCM7364, 0xfffffff0, },
 	{ PHY_ID_BCM7366, 0xfffffff0, },
 	{ PHY_ID_BCM7439, 0xfffffff0, },
 	{ PHY_ID_BCM7445, 0xfffffff0, },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index cbcfad36d4c0..5bd35cc0d471 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -13,6 +13,8 @@
 #define PHY_ID_BCM5461			0x002060c0
 #define PHY_ID_BCM57780			0x03625d90
 
+#define PHY_ID_BCM7250			0xae025280
+#define PHY_ID_BCM7364			0xae025260
 #define PHY_ID_BCM7366			0x600d8490
 #define PHY_ID_BCM7439			0x600d8480
 #define PHY_ID_BCM7445			0x600d8510
-- 
1.9.1
