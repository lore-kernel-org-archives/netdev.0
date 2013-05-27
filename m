From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] net: phy: fix a bug when verify the EEE support
Date: Mon, 27 May 2013 09:31:28 +0200
Message-ID: <1369639888-11805-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:52815 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754364Ab3E0HwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 03:52:06 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 546F11EE
	for <netdev@vger.kernel.org>; Mon, 27 May 2013 07:31:37 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DB82A4536
	for <netdev@vger.kernel.org>; Mon, 27 May 2013 07:31:21 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy_init_eee has to exit with an error when the
local device and its link partner both do not support EEE.
So this patch fixes a problem when verify this.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/phy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c14f147..38f0b31 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1044,7 +1044,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 		adv = mmd_eee_adv_to_ethtool_adv_t(eee_adv);
 		lp = mmd_eee_adv_to_ethtool_adv_t(eee_lp);
 		idx = phy_find_setting(phydev->speed, phydev->duplex);
-		if ((lp & adv & settings[idx].setting))
+		if (!(lp & adv & settings[idx].setting))
 			goto eee_exit;
 
 		if (clk_stop_enable) {
-- 
1.7.4.4
