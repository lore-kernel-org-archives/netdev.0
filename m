From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/5] stmmac: fix advertising 1000Base capabilties for non GMII iface
Date: Thu, 17 Nov 2011 08:57:59 +0100
Message-ID: <1321516682-32208-2-git-send-email-peppe.cavallaro@st.com>
References: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Cc: francesco.virlinzi@st.com, srinivas.kandagatla@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:58440 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab1KQH6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 02:58:16 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 14B302DB
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 07:58:13 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D99C618F6
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 07:58:13 +0000 (GMT)
In-Reply-To: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch fixes the way to stop the 1000Base advertising
capabilties for non GMII interfaces.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 20546bb..e079762 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -321,12 +321,10 @@ static int stmmac_init_phy(struct net_device *dev)
 	}
 
 	/* Stop Advertising 1000BASE Capability if interface is not GMII */
-	if ((interface) && ((interface == PHY_INTERFACE_MODE_MII) ||
-	    (interface == PHY_INTERFACE_MODE_RMII))) {
-		phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
-				      SUPPORTED_Asym_Pause);
-		phydev->advertising = phydev->supported;
-	}
+	if ((interface == PHY_INTERFACE_MODE_MII) ||
+	    (interface == PHY_INTERFACE_MODE_RMII))
+		phydev->advertising &= ~(SUPPORTED_1000baseT_Half |
+					 SUPPORTED_1000baseT_Full);
 
 	/*
 	 * Broken HW is sometimes missing the pull-up resistor on the
-- 
1.7.4.4
