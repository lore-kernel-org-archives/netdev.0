From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH 3.3.0] phy:icplus:fix Auto Power Saving in ip101a_config_init.
Date: Mon,  2 Apr 2012 11:02:09 +0100
Message-ID: <1333360929-31506-1-git-send-email-srinivas.kandagatla@st.com>
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
	srinivas.kandagatla@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:47496 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751465Ab2DBKD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 06:03:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch fixes Auto Power Saving configuration in ip101a_config_init
which was broken as there is no phy register write followed after
setting IP101A_APS_ON flag.

This patch also fixes the return value of ip101a_config_init.

Without this patch ip101a_config_init returns 2 which is not an error
accroding to IS_ERR and the mac driver will continue accessing 2 as
valid pointer to phy_dev resulting in memory fault.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
Hi All, 
This patch fixes broken ip101a_config_init in icplus.c.

Thanks,
srini

 drivers/net/phy/icplus.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 0856e1b..f08c85a 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -162,7 +162,8 @@ static int ip101a_g_config_init(struct phy_device *phydev)
 	/* Enable Auto Power Saving mode */
 	c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
 	c |= IP101A_G_APS_ON;
-	return c;
+
+	return phy_write(phydev, IP10XX_SPEC_CTRL_STATUS, c);
 }
 
 static int ip175c_read_status(struct phy_device *phydev)
-- 
1.7.0.4
