From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] sungem: Marvell PHY suspend
Date: Sun, 16 Apr 2006 02:52:17 +0200
Message-ID: <1145148738.6560.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:49055 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932180AbWDPAw0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 20:52:26 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a short discussion with Benjamin Herrenschmidt he mentioned
that Marvell PHYs are powered down the same way as the other
ones we currently handle. Thus actually do that, hopefully
saving some power during suspend.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>

--- a/drivers/net/sungem_phy.c
+++ b/drivers/net/sungem_phy.c
@@ -275,7 +275,7 @@ static int bcm5411_init(struct mii_phy* 
 	return 0;
 }
 
-static int bcm5411_suspend(struct mii_phy* phy)
+static int generic_suspend(struct mii_phy* phy)
 {
 	phy_write(phy, MII_BMCR, BMCR_PDOWN);
 
@@ -738,7 +738,7 @@ static struct mii_phy_def bcm5401_phy_de
 /* Broadcom BCM 5411 */
 static struct mii_phy_ops bcm5411_phy_ops = {
 	.init		= bcm5411_init,
-	.suspend	= bcm5411_suspend,
+	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
 	.setup_forced	= bcm54xx_setup_forced,
 	.poll_link	= genmii_poll_link,
@@ -757,7 +757,7 @@ static struct mii_phy_def bcm5411_phy_de
 /* Broadcom BCM 5421 */
 static struct mii_phy_ops bcm5421_phy_ops = {
 	.init		= bcm5421_init,
-	.suspend	= bcm5411_suspend,
+	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
 	.setup_forced	= bcm54xx_setup_forced,
 	.poll_link	= genmii_poll_link,
@@ -776,7 +776,7 @@ static struct mii_phy_def bcm5421_phy_de
 /* Broadcom BCM 5421 built-in K2 */
 static struct mii_phy_ops bcm5421k2_phy_ops = {
 	.init		= bcm5421_init,
-	.suspend	= bcm5411_suspend,
+	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
 	.setup_forced	= bcm54xx_setup_forced,
 	.poll_link	= genmii_poll_link,
@@ -795,7 +795,7 @@ static struct mii_phy_def bcm5421k2_phy_
 /* Broadcom BCM 5462 built-in Vesta */
 static struct mii_phy_ops bcm5462V_phy_ops = {
 	.init		= bcm5421_init,
-	.suspend	= bcm5411_suspend,
+	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
 	.setup_forced	= bcm54xx_setup_forced,
 	.poll_link	= genmii_poll_link,
@@ -816,6 +816,7 @@ static struct mii_phy_def bcm5462V_phy_d
  * would be useful here) --BenH.
  */
 static struct mii_phy_ops marvell_phy_ops = {
+	.suspend	= generic_suspend,
 	.setup_aneg	= marvell_setup_aneg,
 	.setup_forced	= marvell_setup_forced,
 	.poll_link	= genmii_poll_link,


