From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH 3.3.0 2/3] net:phy:davicom: remove unnecessary code
Date: Mon,  2 Apr 2012 17:25:11 +0100
Message-ID: <1333383911-24311-1-git-send-email-srinivas.kandagatla@st.com>
Cc: davem@davemloft.net, srinivas.kandagatla@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:57980 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751548Ab2DBQ1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 12:27:00 -0400
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
 drivers/net/phy/davicom.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 2f774ac..5f59cc0 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -134,12 +134,7 @@ static int dm9161_config_init(struct phy_device *phydev)
 		return err;
 
 	/* Reconnect the PHY, and enable Autonegotiation */
-	err = phy_write(phydev, MII_BMCR, BMCR_ANENABLE);
-
-	if (err < 0)
-		return err;
-
-	return 0;
+	return phy_write(phydev, MII_BMCR, BMCR_ANENABLE);
 }
 
 static int dm9161_ack_interrupt(struct phy_device *phydev)
-- 
1.7.0.4
