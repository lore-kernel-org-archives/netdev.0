From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: re-apply PHY fixups during phy_register_device
Date: Mon, 28 Jul 2014 14:57:25 -0700
Message-ID: <1406584645-20081-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jogo@openwrt.org, hauke@hauke-m.de,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:63338 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbaG1V5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 17:57:32 -0400
Received: by mail-pa0-f46.google.com with SMTP id lj1so11207450pab.19
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 14:57:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 87aa9f9c61ad ("net: phy: consolidate PHY reset in phy_init_hw()")
moved the call to phy_scan_fixups() in phy_init_hw() after a software
reset is performed.

This broke PHY drivers which do register an early PHY fixup callback to
intercept the PHY probing and do things like changing the 32-bits unique
PHY identifier when a pseudo-PHY address has been used.

Reported-by: Hauke Mehrtens <hauke@hauke-m.de>
Reported-by: Jonas Gorski <jogo@openwrt.org>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
This changes is applicable to 3.14+ thanks!

 drivers/net/phy/phy_device.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 74a82328dd49..1759d54682c8 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -355,6 +355,7 @@ int phy_device_register(struct phy_device *phydev)
 	phydev->bus->phy_map[phydev->addr] = phydev;
 
 	/* Run all of the fixups for this PHY */
+	phy_scan_fixups(phydev);
 	err = phy_init_hw(phydev);
 	if (err) {
 		pr_err("PHY %d failed to initialize\n", phydev->addr);
-- 
1.9.1
