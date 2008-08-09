From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] sky2: Fix suspend/hibernation/shutdown regression with WOL enabled
Date: Sat, 9 Aug 2008 23:32:28 +0200
Message-ID: <200808092332.29596.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:46917 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659AbYHIVaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Aug 2008 17:30:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sky2: Fix suspend/hibernation/shutdown regression with WOL enabled

On my test box with the Asus M3A32-MVP main board there is a
regression from 2.6.26 related to suspend, hibernation and
shutdown.  Namely, if Wake-on-LAN is enabled with
'ethtool -s eth0 wol g', the box hangs solid during all of these
operations, while executing either sky2_suspend(), or
sky2_shutdown().  This patch fixes it for me.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/sky2.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/drivers/net/sky2.c
===================================================================
--- linux-2.6.orig/drivers/net/sky2.c
+++ linux-2.6/drivers/net/sky2.c
@@ -665,7 +665,8 @@ static void sky2_phy_power_down(struct s
 		    GM_GPCR_FL_PASS | GM_GPCR_SPEED_100 | GM_GPCR_AU_ALL_DIS);
 
 	if (hw->chip_id != CHIP_ID_YUKON_EC) {
-		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+		if (hw->chip_id == CHIP_ID_YUKON_EC_U
+		    && hw->chip_rev != CHIP_REV_YU_EC_U_B0) {
 			ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
 
 			/* enable Power Down */
