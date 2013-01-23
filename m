From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/2] net: phy: icplus: fix broken INTR pin settings
Date: Wed, 23 Jan 2013 11:22:37 +0100
Message-ID: <1358936557-31540-2-git-send-email-peppe.cavallaro@st.com>
References: <1358936557-31540-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:55209 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754509Ab3AWKW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 05:22:56 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 2F17B1C1
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 10:22:53 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id F1A022B74
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 10:22:52 +0000 (GMT)
In-Reply-To: <1358936557-31540-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>

This patch fixes the setting of the INTR pin that is
valid for IP101 A/G device and not for the IP1001.

Reported-by: Anunay Saxena <anunay.saxena@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/icplus.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index c0e0924..b5ddd50 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -139,11 +139,6 @@ static int ip1001_config_init(struct phy_device *phydev)
 	if (c < 0)
 		return c;
 
-	/* INTR pin used: speed/link/duplex will cause an interrupt */
-	c = phy_write(phydev, IP101A_G_IRQ_CONF_STATUS, IP101A_G_IRQ_DEFAULT);
-	if (c < 0)
-		return c;
-
 	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
@@ -178,6 +173,11 @@ static int ip101a_g_config_init(struct phy_device *phydev)
 	if (c < 0)
 		return c;
 
+	/* INTR pin used: speed/link/duplex will cause an interrupt */
+	c = phy_write(phydev, IP101A_G_IRQ_CONF_STATUS, IP101A_G_IRQ_DEFAULT);
+	if (c < 0)
+		return c;
+
 	/* Enable Auto Power Saving mode */
 	c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
 	c |= IP101A_G_APS_ON;
-- 
1.7.4.4
