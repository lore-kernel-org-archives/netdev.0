From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: FE+ Phy initialization
Date: Mon, 24 Sep 2007 19:34:51 -0700
Message-ID: <20070924193451.7552b9e9@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45314 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756630AbXIYCfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 22:35:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One more snippet of PHY initialization required for FE+ chips.
Discovered in latest sk98lin 10.21.1.3 driver.

Please apply to 2.6.23.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-09-24 09:10:36.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-24 10:22:28.000000000 -0700
@@ -338,6 +338,16 @@ static void sky2_phy_init(struct sky2_hw
 		if (!(hw->flags & SKY2_HW_GIGABIT)) {
 			/* enable automatic crossover */
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO) >> 1;
+
+			if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+			    hw->chip_rev == CHIP_REV_YU_FE2_A0) {
+				u16 spec;
+
+				/* Enable Class A driver for FE+ A0 */
+				spec = gm_phy_read(hw, port, PHY_MARV_FE_SPEC_2);
+				spec |= PHY_M_FESC_SEL_CL_A;
+				gm_phy_write(hw, port, PHY_MARV_FE_SPEC_2, spec);
+			}
 		} else {
 			/* disable energy detect */
 			ctrl &= ~PHY_M_PC_EN_DET_MSK;
