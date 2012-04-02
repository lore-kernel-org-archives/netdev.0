From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH 3.3.0 1/3] net:phy:bcm63xx: remove unnecessary code
Date: Mon,  2 Apr 2012 17:24:55 +0100
Message-ID: <1333383895-23889-1-git-send-email-srinivas.kandagatla@st.com>
Cc: davem@davemloft.net, srinivas.kandagatla@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:54664 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751345Ab2DBQ0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 12:26:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Compile tested.
remove unnecessary code that matches this coccinelle pattern

	ret = phy_write(x, y , z)
	if (ret < 0)
		return ret;
	return 0;

As phy_write returns error code, we dont need to do not need extra check
before returning.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/phy/bcm63xx.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
index e16f98c..cd802eb 100644
--- a/drivers/net/phy/bcm63xx.c
+++ b/drivers/net/phy/bcm63xx.c
@@ -39,10 +39,7 @@ static int bcm63xx_config_init(struct phy_device *phydev)
 		MII_BCM63XX_IR_SPEED |
 		MII_BCM63XX_IR_LINK) |
 		MII_BCM63XX_IR_EN;
-	err = phy_write(phydev, MII_BCM63XX_IR, reg);
-	if (err < 0)
-		return err;
-	return 0;
+	return phy_write(phydev, MII_BCM63XX_IR, reg);
 }
 
 static int bcm63xx_ack_interrupt(struct phy_device *phydev)
-- 
1.7.0.4
