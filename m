From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/2] Rename SMSC phy functions to be more generic
Date: Mon, 28 Apr 2008 18:36:46 +0100
Message-ID: <1209404206-32551-1-git-send-email-steve.glendinning@smsc.com>
Cc: Jeff Garzik <jeff@garzik.org>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sandgatehouse.force9.co.uk ([84.92.144.20]:42420 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932424AbYD1XhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 19:37:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several models of SMSC PHY have the same interrupt status and mask
registers as the LAN83C185, so these functions can service multiple
different PHY drivers.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/phy/smsc.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index b1d8ed4..6a901f0 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -38,7 +38,7 @@
 	(MII_LAN83C185_ISF_INT6 | MII_LAN83C185_ISF_INT4)
 
 
-static int lan83c185_config_intr(struct phy_device *phydev)
+static int smsc_phy_config_intr(struct phy_device *phydev)
 {
 	int rc = phy_write (phydev, MII_LAN83C185_IM,
 			((PHY_INTERRUPT_ENABLED == phydev->interrupts)
@@ -48,16 +48,16 @@ static int lan83c185_config_intr(struct phy_device *phydev)
 	return rc < 0 ? rc : 0;
 }
 
-static int lan83c185_ack_interrupt(struct phy_device *phydev)
+static int smsc_phy_ack_interrupt(struct phy_device *phydev)
 {
 	int rc = phy_read (phydev, MII_LAN83C185_ISF);
 
 	return rc < 0 ? rc : 0;
 }
 
-static int lan83c185_config_init(struct phy_device *phydev)
+static int smsc_phy_config_init(struct phy_device *phydev)
 {
-	return lan83c185_ack_interrupt (phydev);
+	return smsc_phy_ack_interrupt (phydev);
 }
 
 
@@ -73,11 +73,11 @@ static struct phy_driver lan83c185_driver = {
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
-	.config_init	= lan83c185_config_init,
+	.config_init	= smsc_phy_config_init,
 
 	/* IRQ related */
-	.ack_interrupt	= lan83c185_ack_interrupt,
-	.config_intr	= lan83c185_config_intr,
+	.ack_interrupt	= smsc_phy_ack_interrupt,
+	.config_intr	= smsc_phy_config_intr,
 
 	.driver		= { .owner = THIS_MODULE, }
 };
-- 
1.5.4.1

