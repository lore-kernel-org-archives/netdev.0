From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: fix PHY setup on FE-P
Date: Fri, 14 Sep 2007 15:38:06 +0200
Message-ID: <20070914153806.0c282228@oldman>
References: <20070829193922.078561651@linux-foundation.org>
	<20070829195842.694250637@linux-foundation.org>
	<46D81B1E.8020205@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36493 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752839AbXINNh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 09:37:28 -0400
In-Reply-To: <46D81B1E.8020205@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marvell reported the following fix is necessary to get fe-plus
chips to work.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-09-14 14:40:35.000000000 +0200
+++ b/drivers/net/sky2.c	2007-09-14 14:41:00.000000000 +0200
@@ -488,11 +488,12 @@ static void sky2_phy_init(struct sky2_hw
 
 	case CHIP_ID_YUKON_FE_P:
 		/* Enable Link Partner Next Page */
+		ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
 		ctrl |= PHY_M_PC_ENA_LIP_NP;
 
 		/* disable Energy Detect and enable scrambler */
 		ctrl &= ~(PHY_M_PC_ENA_ENE_DT | PHY_M_PC_DIS_SCRAMB);
-		gm_phy_write(hw, port, PHY_MARV_CTRL, ctrl);
+		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
 
 		/* set LED2 -> ACT, LED1 -> LINK, LED0 -> SPEED */
 		ctrl = PHY_M_FELP_LED2_CTRL(LED_PAR_CTRL_ACT_BL) |
