From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] net: phy: rtl8211: fix interrupt on status link change
Date: Mon, 19 Aug 2013 08:48:34 +0200
Message-ID: <1376894914-11174-1-git-send-email-peppe.cavallaro@st.com>
References: <A1A6EA40F8503D48BB002B42BD65974E0A0E6C8C@039-SN2MPN1-012.039d.mgd.msft.net>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog122.obsmtp.com ([207.126.144.153]:33411 "EHLO
	eu1sys200aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750885Ab3HSGyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 02:54:18 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 836441C9
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 06:54:04 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 427862CD2
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 06:53:35 +0000 (GMT)
In-Reply-To: <A1A6EA40F8503D48BB002B42BD65974E0A0E6C8C@039-SN2MPN1-012.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to fix a problem in the rtl8211 where the driver
wasn't properly enabled the interrupt on link change status.
it has to enable the ineterrupt on the bit 10 in the register 18
(INER).

Reported-by: Sharma Bhupesh <B45370@freescale.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/realtek.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 8e7af83..138de83 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -23,7 +23,7 @@
 #define RTL821x_INER_INIT	0x6400
 #define RTL821x_INSR		0x13
 
-#define	RTL8211E_INER_LINK_STAT	0x10
+#define	RTL8211E_INER_LINK_STATUS	0x400
 
 MODULE_DESCRIPTION("Realtek PHY driver");
 MODULE_AUTHOR("Johnson Leung");
@@ -57,7 +57,7 @@ static int rtl8211e_config_intr(struct phy_device *phydev)
 
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
 		err = phy_write(phydev, RTL821x_INER,
-				RTL8211E_INER_LINK_STAT);
+				RTL8211E_INER_LINK_STATUS);
 	else
 		err = phy_write(phydev, RTL821x_INER, 0);
 
-- 
1.7.4.4
