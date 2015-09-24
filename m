From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 7/9] phy: fixed-phy: properly validate phy in
 fixed_phy_update_state()
Date: Thu, 24 Sep 2015 20:18:53 +0100
Message-ID: <E1ZfC2f-00036G-5M@rmk-PC.arm.linux.org.uk>
References: <20150924191754.GC21513@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:44822 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbbIXTTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 15:19:03 -0400
In-Reply-To: <20150924191754.GC21513@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Validate that the phy_device passed into fixed_phy_update_state() is a
fixed-phy device before walking the list of phys for a fixed phy at the
same address.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/fixed_phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index fb1299c6326e..e23bf5b90e17 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -220,7 +220,7 @@ int fixed_phy_update_state(struct phy_device *phydev,
 	struct fixed_mdio_bus *fmb = &platform_fmb;
 	struct fixed_phy *fp;
 
-	if (!phydev || !phydev->bus)
+	if (!phydev || phydev->bus != fmb->mii_bus)
 		return -EINVAL;
 
 	list_for_each_entry(fp, &fmb->phys, node) {
-- 
2.1.0
