From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/7] net: phy: allow phy_init_eee() to work with internal PHYs
Date: Fri, 22 Aug 2014 18:55:44 -0700
Message-ID: <1408758945-18908-7-git-send-email-f.fainelli@gmail.com>
References: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:55412 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbaHWB4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 21:56:20 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so16489951pdj.15
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 18:56:20 -0700 (PDT)
In-Reply-To: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Internal PHYs do not have any specific phy_interface_t defined because
they are within an Ethernet MAC or a larger IC, they will fail the early
check in phy_init_eee(). Allow these PHYs to proceed with EEE
initialization and report error/success by checking the standard C45
EEE-related registers.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index e7a5893f32ff..932190e04d08 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1019,12 +1019,14 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 {
 	/* According to 802.3az,the EEE is supported only in full duplex-mode.
 	 * Also EEE feature is active when core is operating with MII, GMII
-	 * or RGMII.
+	 * or RGMII. Internal PHYs are also allowed to proceed and should
+	 * return an error if they do not support EEE.
 	 */
 	if ((phydev->duplex == DUPLEX_FULL) &&
 	    ((phydev->interface == PHY_INTERFACE_MODE_MII) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_GMII) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_RGMII))) {
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
+	     phy_is_internal(phydev))) {
 		int eee_lp, eee_cap, eee_adv;
 		u32 lp, cap, adv;
 		int status;
-- 
1.9.1
