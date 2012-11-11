From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH v2 1/3] net/phy/davicom: add irq functions to DM9161E and DM9161A
Date: Mon, 12 Nov 2012 00:56:26 +0100
Message-ID: <1352678188-18647-2-git-send-email-manabian@gmail.com>
References: <1352678188-18647-1-git-send-email-manabian@gmail.com>
Cc: plagnioj@jcrosoft.com, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:41944 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab2KKX4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 18:56:34 -0500
Received: by mail-la0-f46.google.com with SMTP id h6so4165513lag.19
        for <netdev@vger.kernel.org>; Sun, 11 Nov 2012 15:56:32 -0800 (PST)
In-Reply-To: <1352678188-18647-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both these PHYs support interrupt generation on IC pin 32.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/phy/davicom.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 81c7bc0..383e833 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -150,18 +150,24 @@ static struct phy_driver dm91xx_driver[] = {
 	.name		= "Davicom DM9161E",
 	.phy_id_mask	= 0x0ffffff0,
 	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
+	.ack_interrupt	= dm9161_ack_interrupt,
+	.config_intr	= dm9161_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x0181b8a0,
 	.name		= "Davicom DM9161A",
 	.phy_id_mask	= 0x0ffffff0,
 	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
+	.ack_interrupt	= dm9161_ack_interrupt,
+	.config_intr	= dm9161_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x00181b80,
-- 
1.8.0
