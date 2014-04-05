From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: [PATCH net] Remove unnecessary condition check in phy
Date: Sat, 05 Apr 2014 13:00:16 +0530
Message-ID: <533FB108.6010508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:54856 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320AbaDEHaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2014 03:30:21 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so4420048pbc.24
        for <netdev@vger.kernel.org>; Sat, 05 Apr 2014 00:30:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This condition check makes no difference in the code flow since 3.10

Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
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

-       } else if (0 == phydev->link_timeout--) {
+       } else if (0 == phydev->link_timeout--)
            needs_aneg = 1;
-           /* If we have the magic_aneg bit, we try again */
-           if (phydev->drv->flags & PHY_HAS_MAGICANEG)
-               break;
-       }
        break;
    case PHY_NOLINK:
        err = phy_read_status(phydev);
-- 
1.7.9.5
