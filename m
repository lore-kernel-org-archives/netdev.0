From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: [PATCH v2] net phylib: Remove unnecessary condition check
Date: Tue, 08 Apr 2014 20:51:05 +0530
Message-ID: <534413E1.8070205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:64113 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932141AbaDHPVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 11:21:36 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so1141805pdi.5
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 08:21:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This condition check makes no difference in the code flow since 3.10

Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

---
 drivers/net/phy/phy.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 1d788f1..1b6d09a 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -756,12 +756,8 @@ void phy_state_machine(struct work_struct *work)
			netif_carrier_on(phydev->attached_dev);
			phydev->adjust_link(phydev->attached_dev);

-		} else if (0 == phydev->link_timeout--) {
+		} else if (0 == phydev->link_timeout--)
			needs_aneg = 1;
-			/* If we have the magic_aneg bit, we try again */
-			if (phydev->drv->flags & PHY_HAS_MAGICANEG)
-				break;
-		}
		break;
	case PHY_NOLINK:
		err = phy_read_status(phydev);
-- 1.7.9.5 
