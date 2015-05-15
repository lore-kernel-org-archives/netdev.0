From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: Allow EEE for all RGMII variants
Date: Fri, 15 May 2015 16:30:41 -0700
Message-ID: <1431732641-17683-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linux@roeck-us.net, peppe.cavallaro@st.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34225 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423264AbbEOXbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 19:31:04 -0400
Received: by pdeq5 with SMTP id q5so32379173pde.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 16:31:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RGMII interfaces come in multiple flavors: RGMII with transmit or
receive internal delay, no delays at all, or delays in both direction.

This change extends the initial check for PHY_INTERFACE_MODE_RGMII to
cover all of these variants since EEE should be allowed for any of these
modes, since it is a property of the RGMII, hence Gigabit PHY capability
more than the RGMII electrical interface and its delays.

Fixes: a59a4d192166 ("phy: add the EEE support and the way to access to the MMD registers")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
David this change dates back to 3.6, however the comment update will depend on
a9f6309585cbefa4a7f08c9017ca482c3222323a ("net: phy: allow phy_init_eee() to
work with internal PHYs") to be included, which is only 3.18, nobody but me
really complained about that so I guess 3.18+ is reasonable.

 drivers/net/phy/phy.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 52cd8db2c57d..757f28a4284c 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1053,13 +1053,14 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 {
 	/* According to 802.3az,the EEE is supported only in full duplex-mode.
 	 * Also EEE feature is active when core is operating with MII, GMII
-	 * or RGMII. Internal PHYs are also allowed to proceed and should
-	 * return an error if they do not support EEE.
+	 * or RGMII (all kinds). Internal PHYs are also allowed to proceed and
+	 * should return an error if they do not support EEE.
 	 */
 	if ((phydev->duplex == DUPLEX_FULL) &&
 	    ((phydev->interface == PHY_INTERFACE_MODE_MII) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_GMII) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
+	    (phydev->interface >= PHY_INTERFACE_MODE_RGMII &&
+	     phydev->interface <= PHY_INTERFACE_MODE_RGMII_TXID) ||
 	     phy_is_internal(phydev))) {
 		int eee_lp, eee_cap, eee_adv;
 		u32 lp, cap, adv;
-- 
2.1.0
