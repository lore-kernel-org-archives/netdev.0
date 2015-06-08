From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: bcm7xxx: update workaround to fix 100BaseT corner cases
Date: Mon,  8 Jun 2015 11:05:20 -0700
Message-ID: <1433786720-5920-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36557 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbbFHSG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 14:06:27 -0400
Received: by qkx62 with SMTP id 62so81972431qkx.3
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 11:06:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the AFE_TX_CONFIG value to solve marginal rise/fall issues
observed when the link is operating in 100BaseT. This workaround applies
to GPHY revisions D0, E0 and newer.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index b5dc59de094e..4dea85bfc545 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -136,8 +136,8 @@ static int bcm7xxx_28nm_d0_afe_config_init(struct phy_device *phydev)
 	/* AFE_RX_LP_COUNTER, set RX bandwidth to maximum */
 	phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc0);
 
-	/* AFE_TX_CONFIG, set 1000BT Cfeed=110 for all ports */
-	phy_write_misc(phydev, AFE_TX_CONFIG, 0x0061);
+	/* AFE_TX_CONFIG, set 100BT Cfeed=011 to improve rise/fall time */
+	phy_write_misc(phydev, AFE_TX_CONFIG, 0x431);
 
 	/* AFE_VDCA_ICTRL_0, set Iq=1101 instead of 0111 for AB symmetry */
 	phy_write_misc(phydev, AFE_VDCA_ICTRL_0, 0xa7da);
@@ -167,6 +167,9 @@ static int bcm7xxx_28nm_e0_plus_afe_config_init(struct phy_device *phydev)
 	/* AFE_RXCONFIG_1, provide more margin for INL/DNL measurement */
 	phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9b2f);
 
+	/* AFE_TX_CONFIG, set 100BT Cfeed=011 to improve rise/fall time */
+	phy_write_misc(phydev, AFE_TX_CONFIG, 0x431);
+
 	/* AFE_VDCA_ICTRL_0, set Iq=1101 instead of 0111 for AB symmetry */
 	phy_write_misc(phydev, AFE_VDCA_ICTRL_0, 0xa7da);
 
-- 
2.1.0
