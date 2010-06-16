From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH] broadcom: Add 5241 support
Date: Wed, 16 Jun 2010 18:38:46 +0400
Message-ID: <1276699126-8168-1-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61477 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071Ab0FPOiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 10:38:46 -0400
Received: by bwz7 with SMTP id 7so3174597bwz.19
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 07:38:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 5241 PHY ID to the broadcom module.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/net/phy/broadcom.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index f482fc4..1c12a57 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -834,6 +834,21 @@ static struct phy_driver bcmac131_driver = {
 	.driver		= { .owner = THIS_MODULE },
 };
 
+static struct phy_driver bcm5241_driver = {
+	.phy_id		= 0x0143bc30,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM5241",
+	.features	= PHY_BASIC_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= brcm_fet_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= brcm_fet_ack_interrupt,
+	.config_intr	= brcm_fet_config_intr,
+	.driver		= { .owner = THIS_MODULE },
+};
+
 static int __init broadcom_init(void)
 {
 	int ret;
@@ -868,8 +883,13 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcmac131_driver);
 	if (ret)
 		goto out_ac131;
+	ret = phy_driver_register(&bcm5241_driver);
+	if (ret)
+		goto out_5241;
 	return ret;
 
+out_5241:
+	phy_driver_unregister(&bcmac131_driver);
 out_ac131:
 	phy_driver_unregister(&bcm57780_driver);
 out_57780:
@@ -894,6 +914,7 @@ out_5411:
 
 static void __exit broadcom_exit(void)
 {
+	phy_driver_unregister(&bcm5241_driver);
 	phy_driver_unregister(&bcmac131_driver);
 	phy_driver_unregister(&bcm57780_driver);
 	phy_driver_unregister(&bcm50610m_driver);
-- 
1.7.1

