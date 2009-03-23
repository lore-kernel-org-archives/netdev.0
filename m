From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] phy: add new LAN8710 and LAN8720 device ids to smsc phy driver
Date: Mon, 23 Mar 2009 18:22:37 +0000
Message-ID: <1237832557-3713-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:53134 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758024AbZCWSWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 14:22:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LAN8710 and LAN8720 are two new 10/100 ethernet PHY models. The two
share the same phy id, this patch adds it to the smsc phy driver.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/phy/smsc.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 1387187..5123bb9 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -159,6 +159,30 @@ static struct phy_driver lan911x_int_driver = {
 	.driver		= { .owner = THIS_MODULE, }
 };
 
+static struct phy_driver lan8710_driver = {
+	.phy_id		= 0x0007c0f0, /* OUI=0x00800f, Model#=0x0f */
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "SMSC LAN8710/LAN8720",
+
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
+
+	/* basic functions */
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.config_init	= smsc_phy_config_init,
+
+	/* IRQ related */
+	.ack_interrupt	= smsc_phy_ack_interrupt,
+	.config_intr	= smsc_phy_config_intr,
+
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
+
+	.driver		= { .owner = THIS_MODULE, }
+};
+
 static int __init smsc_init(void)
 {
 	int ret;
@@ -179,8 +203,14 @@ static int __init smsc_init(void)
 	if (ret)
 		goto err4;
 
+	ret = phy_driver_register (&lan8710_driver);
+	if (ret)
+		goto err5;
+
 	return 0;
 
+err5:
+	phy_driver_unregister (&lan911x_int_driver);
 err4:
 	phy_driver_unregister (&lan8700_driver);
 err3:
@@ -193,6 +223,7 @@ err1:
 
 static void __exit smsc_exit(void)
 {
+	phy_driver_unregister (&lan8710_driver);
 	phy_driver_unregister (&lan911x_int_driver);
 	phy_driver_unregister (&lan8700_driver);
 	phy_driver_unregister (&lan8187_driver);
-- 
1.6.0.6

