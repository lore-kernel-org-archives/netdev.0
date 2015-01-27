From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next] net: phy: Invalidate LP advertising flags when
 restarting or disabling AN
Date: Tue, 27 Jan 2015 00:58:15 +0000
Message-ID: <1422320295.3524.26.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:50416 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbbA0A6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:58:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible to see the old value of the LP advertising flags
through ethtool after reconfiguring the PHY and before autonegotiation
completes.  If autonegotiation is turned off then the last value seen
will persist indefinitely.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/phy/phy.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 767cd11..cdcac6a 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -439,6 +439,9 @@ int phy_start_aneg(struct phy_device *phydev)
 	if (AUTONEG_DISABLE == phydev->autoneg)
 		phy_sanitize_settings(phydev);
 
+	/* Invalidate LP advertising flags */
+	phydev->lp_advertising = 0;
+
 	err = phydev->drv->config_aneg(phydev);
 	if (err < 0)
 		goto out_unlock;
-- 
1.7.10.4
