From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: fix regression on Yukon Optima
Date: Fri, 4 Nov 2011 15:17:17 -0700
Message-ID: <20111104151717.0f4666ac@nehalam.linuxnetplumber.net>
References: <201110171434.50436.pavel@netsafe.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pavel Mateja <pavel@netsafe.cz>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42758 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753132Ab1KDWRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 18:17:20 -0400
In-Reply-To: <201110171434.50436.pavel@netsafe.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to support other Optima types, introduced an accidental
regression that caused 88E8059 to come up in 10Mbit/sec.

The Yukon Optima supports a reverse auto-negotiation feature that
was incorrectly setup, and not needed. The feature could be used to
allow wake-on-lan at higher speeds. But doing it correctly would require
other changes to initialization.

Reported-by: Pavel Mateja <pavel@netsafe.cz>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This version is for current driver organization (post 3.1).
Same fix applies but to drivers/net/sky2.c in -stable.

--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-02 15:38:11.677011133 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-04 15:01:51.310888300 -0700
@@ -366,17 +366,6 @@ static void sky2_phy_init(struct sky2_hw
 				gm_phy_write(hw, port, PHY_MARV_FE_SPEC_2, spec);
 			}
 		} else {
-			if (hw->chip_id >= CHIP_ID_YUKON_OPT) {
-				u16 ctrl2 = gm_phy_read(hw, port, PHY_MARV_EXT_CTRL_2);
-
-				/* enable PHY Reverse Auto-Negotiation */
-				ctrl2 |= 1u << 13;
-
-				/* Write PHY changes (SW-reset must follow) */
-				gm_phy_write(hw, port, PHY_MARV_EXT_CTRL_2, ctrl2);
-			}
-
-
 			/* disable energy detect */
 			ctrl &= ~PHY_M_PC_EN_DET_MSK;
 
