From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: Add missing driver check in phy_aneg_done()
Date: Thu, 23 Feb 2017 14:22:19 -0800
Message-ID: <20170223222219.6915-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, dan.carpenter@oracle.com,
        rmk+kernel@armlinux.org.uk, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36831 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751282AbdBWWWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 17:22:32 -0500
Received: by mail-pf0-f196.google.com with SMTP id c193so120165pfb.3
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 14:22:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan's static checker caught a potential code path in phy_state_machine() where
we were not checking phydev->drv which is in phy_aneg_done().

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 25149ef9d25c ("net: phy: Check phydev->drv")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d6f7838455dd..1be69d8bc909 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -146,7 +146,7 @@ static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
  */
 int phy_aneg_done(struct phy_device *phydev)
 {
-	if (phydev->drv->aneg_done)
+	if (phydev->drv && phydev->drv->aneg_done)
 		return phydev->drv->aneg_done(phydev);
 
 	return genphy_aneg_done(phydev);
-- 
2.9.3
