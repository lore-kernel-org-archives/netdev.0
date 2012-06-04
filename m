From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] net: icplus: fix interrupt mask
Date: Mon,  4 Jun 2012 17:51:18 +0200
Message-ID: <1338825078-31856-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:51993 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752966Ab2FDPv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:51:29 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0644DD3
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 15:51:24 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7C515467C
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 15:51:24 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the interrupt mask for IC101 A/G devices
and now enables the link/speed/duplex interrupts.
This is done by setting the "INTR pin used" bit and cleaning
all the other bits in the Register 17.

Reported-by: Stuart Menefy <stuart.menefy@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/icplus.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 5ac46f5..47f8e89 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -41,6 +41,8 @@ MODULE_LICENSE("GPL");
 #define IP1001_APS_ON			11	/* IP1001 APS Mode  bit */
 #define IP101A_G_APS_ON			2	/* IP101A/G APS Mode bit */
 #define IP101A_G_IRQ_CONF_STATUS	0x11	/* Conf Info IRQ & Status Reg */
+#define	IP101A_G_IRQ_PIN_USED		(1<<15) /* INTR pin used */
+#define	IP101A_G_IRQ_DEFAULT		IP101A_G_IRQ_PIN_USED
 
 static int ip175c_config_init(struct phy_device *phydev)
 {
@@ -136,6 +138,11 @@ static int ip1001_config_init(struct phy_device *phydev)
 	if (c < 0)
 		return c;
 
+	/* INTR pin used: speed/link/duplex will cause an interrupt */
+	c = phy_write(phydev, IP101A_G_IRQ_CONF_STATUS, IP101A_G_IRQ_DEFAULT);
+	if (c < 0)
+		return c;
+
 	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
 		/* Additional delay (2ns) used to adjust RX clock phase
 		 * at RGMII interface */
-- 
1.7.4.4
