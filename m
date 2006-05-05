From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: Fix access to non-existent PHY registers
Date: Fri, 5 May 2006 19:50:54 +0200
Message-ID: <200605051950.54391.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:26307
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751697AbWEERoZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 13:44:25 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John, this is the same patch as before, but for d80211.
Please apply to wireless-dev.

--

Fix the conditions under which we poke at the APHY registers in
bcm43xx_phy_initg() to avoid a machine check on chips where they don't
exist.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
index 45da79d..1816f66 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
@@ -1287,7 +1287,7 @@ static void bcm43xx_phy_initg(struct bcm
 	if (radio->revision == 8)
 		bcm43xx_phy_write(bcm, 0x0805, 0x3230);
 	bcm43xx_phy_init_pctl(bcm);
-	if (bcm->chip_id == 0x4306 && bcm->chip_package != 2) {
+	if (bcm->chip_id == 0x4306 && bcm->chip_package == 2) {
 		bcm43xx_phy_write(bcm, 0x0429,
 				  bcm43xx_phy_read(bcm, 0x0429) & 0xBFFF);
 		bcm43xx_phy_write(bcm, 0x04C3,


-- 
Greetings Michael.
