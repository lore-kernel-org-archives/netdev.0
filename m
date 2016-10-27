From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] net: phy: at803x: the Atheros 8031 supports pause frames
Date: Thu, 27 Oct 2016 17:05:01 -0500
Message-ID: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
To: netdev@vger.kernel.org, zefir.kurtisi@neratec.com,
        scampbel@codeaurora.org, alokc@codeaurora.org,
        shankerd@codeaurora.org, andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47490 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933375AbcJ0WFJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 18:05:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Atheros 8031 PHY supports the 802.3 extension for symmetric and
asymmetric pause frames, so set that to the list of features supported
by the phy.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---

Without this patch, my NIC (the Qualcomm EMAC) receives a lot of frame
check sequence (aka CRC) errors, resulting in about 10% packet loss.
Can someone help me understand why?  Because of this patch, I can't use
the generic phy driver in phylib.  Why would a MAC controller require
its PHY to support pause frames?

 drivers/net/phy/at803x.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index a52b560..fb80413 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -440,7 +440,8 @@ static struct phy_driver at803x_driver[] = {
 	.get_wol		= at803x_get_wol,
 	.suspend		= at803x_suspend,
 	.resume			= at803x_resume,
-	.features		= PHY_GBIT_FEATURES,
+	.features		= PHY_GBIT_FEATURES |
+				  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags			= PHY_HAS_INTERRUPT,
 	.config_aneg		= genphy_config_aneg,
 	.read_status		= genphy_read_status,
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
