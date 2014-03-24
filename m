From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/3] net: phy: bcm7xxx: properly clear AFE_RX_LP_COUNTER
Date: Mon, 24 Mar 2014 16:36:49 -0700
Message-ID: <1395704209-30019-4-git-send-email-f.fainelli@gmail.com>
References: <1395704209-30019-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:44913 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbaCXXhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 19:37:05 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so6108219pbc.41
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 16:37:04 -0700 (PDT)
In-Reply-To: <1395704209-30019-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The AFE_RX_LP_COUNTER kept the last 3 bits set, which would not properly
clear the EEE LPI mode errors bits. Make sure that those bits are set to
0 to ensure the PHY timing is always good even during EEE wake-up.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- used named constants

 drivers/net/phy/bcm7xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 5991168bcbef..526b94cea569 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -135,7 +135,7 @@ static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
 	phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9a3f);
 
 	/* write AFE_RX_LP_COUNTER */
-	phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc7);
+	phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc0);
 
 	/* write AFE_HPF_TRIM_OTHERS */
 	phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x000b);
-- 
1.8.3.2
