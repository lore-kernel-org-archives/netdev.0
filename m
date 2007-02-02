From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] sky2 auto negotiation PHY errata
Date: Fri, 2 Feb 2007 11:28:46 -0800
Message-ID: <20070202112846.31acaa03@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36521 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423079AbXBBTbm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 14:31:42 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch does the Marvell errata before auto negotiation
(from drivers/phy/marvell.c).  The Yukon II chips have an internal
version of the same PHY, so perhaps this errata is necessary for them
as well.

For test only, but it may fix some of the hangs. It seems to fix
the PHY lockups I saw yesterday on Mac Mini.

---
 drivers/net/sky2.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 822dd0b..4f04ffa 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -387,6 +387,14 @@ static void sky2_phy_init(struct sky2_hw
 
 	if (sky2->autoneg == AUTONEG_ENABLE) {
 		if (sky2_is_copper(hw)) {
+			/* Errata setup */
+			gm_phy_write(hw, port, PHY_MARV_PAGE_ADDR, 0x1f);
+			gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0x200c);
+			gm_phy_write(hw, port, PHY_MARV_PAGE_ADDR, 5);
+			gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0);
+			gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0x100);
+
+
 			if (sky2->advertising & ADVERTISED_1000baseT_Full)
 				ct1000 |= PHY_M_1000C_AFD;
 			if (sky2->advertising & ADVERTISED_1000baseT_Half)
-- 
1.4.1

