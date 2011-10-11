From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next] net/phy: extra delay only for RGMII interfaces for IC+ IP 1001
Date: Tue, 11 Oct 2011 09:37:56 +0200
Message-ID: <1318318676-4493-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:39147 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750942Ab1JKHiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 03:38:06 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 44BFF18F
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 07:38:04 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 12D271AC6
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 07:38:04 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The extra delay of 2ns to adjust RX clock phase is actually needed
in RGMII mode. Tested on the HDK7108 (STx7108c2).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/icplus.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index d66bd8d..c81f136 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -128,12 +128,15 @@ static int ip1001_config_init(struct phy_device *phydev)
 	if (c < 0)
 		return c;
 
-	/* Additional delay (2ns) used to adjust RX clock phase
-	 * at GMII/ RGMII interface */
-	c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
-	c |= IP1001_PHASE_SEL_MASK;
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
+		/* Additional delay (2ns) used to adjust RX clock phase
+		 * at RGMII interface */
+		c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
+		c |= IP1001_PHASE_SEL_MASK;
+		c = phy_write(phydev, IP10XX_SPEC_CTRL_STATUS, c);
+	}
 
-	return phy_write(phydev, IP10XX_SPEC_CTRL_STATUS, c);
+	return c;
 }
 
 static int ip101a_config_init(struct phy_device *phydev)
-- 
1.7.4.4
