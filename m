From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: phy: bcm7xxx: properly clear AFE_RX_LP_COUNTER
Date: Fri, 14 Mar 2014 16:09:05 -0700
Message-ID: <1394838545-7746-3-git-send-email-f.fainelli@gmail.com>
References: <1394838545-7746-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:40409 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520AbaCNXJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 19:09:20 -0400
Received: by mail-ig0-f169.google.com with SMTP id h18so2920991igc.0
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 16:09:20 -0700 (PDT)
In-Reply-To: <1394838545-7746-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The AFE_RX_LP_COUNTER kept the last 3 bits set, which would not properly
clear the EEE LPI mode errors bits. Make sure that those bits are set to
0 to ensure the PHY timing is always good even during EEE wake-up.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 07d719d6cc3c..91a459c74f23 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -119,7 +119,7 @@ static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
 	phy_write_misc(phydev, 0x38, 0x0001, 0x9a3f);
 
 	/* write AFE_RX_LP_COUNTER */
-	phy_write_misc(phydev, 0x38, 0x0003, 0x7fc7);
+	phy_write_misc(phydev, 0x38, 0x0003, 0x7fc0);
 
 	/* write AFE_HPF_TRIM_OTHERS */
 	phy_write_misc(phydev, 0x3A, 0x0000, 0x000b);
-- 
1.8.3.2
