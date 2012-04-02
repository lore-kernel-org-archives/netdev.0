From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH 3.3.0 3/3] net:phy:marvell: remove unnecessary code
Date: Mon,  2 Apr 2012 17:25:24 +0100
Message-ID: <1333383924-24353-1-git-send-email-srinivas.kandagatla@st.com>
Cc: davem@davemloft.net, srinivas.kandagatla@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:51022 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753115Ab2DBQ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 12:27:10 -0400
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
 drivers/net/phy/marvell.c |   18 +++---------------
 1 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e8b9c53..418928d 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -455,11 +455,7 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
-	if (err < 0)
-		return err;
-
-	return 0;
+	return phy_write(phydev, MII_BMCR, BMCR_RESET);
 }
 
 static int m88e1118_config_aneg(struct phy_device *phydev)
@@ -515,11 +511,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
-	if (err < 0)
-		return err;
-
-	return 0;
+	return phy_write(phydev, MII_BMCR, BMCR_RESET);
 }
 
 static int m88e1149_config_init(struct phy_device *phydev)
@@ -545,11 +537,7 @@ static int m88e1149_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
-	if (err < 0)
-		return err;
-
-	return 0;
+	return phy_write(phydev, MII_BMCR, BMCR_RESET);
 }
 
 static int m88e1145_config_init(struct phy_device *phydev)
-- 
1.7.0.4
