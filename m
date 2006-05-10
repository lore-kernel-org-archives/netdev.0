From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [PATCH 1/2] bcm43xx-d80211: check for valid MAC address in SPROM
 (#2)
Date: Thu, 11 May 2006 01:11:00 +0200
Message-ID: <20060511011100.4a16a06c@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.polimi.it ([131.175.12.3]:31159 "EHLO polimi.it")
	by vger.kernel.org with ESMTP id S965072AbWEJXLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 19:11:24 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the mistake. Now diffed against the right port :). Please apply
to wireless-dev.

--

Check for valid MAC address in SPROM fields instead of relying on PHY type
while setting the MAC address in the networking subsystem, as some devices
have multiple PHYs.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -3934,7 +3934,7 @@ static int bcm43xx_attach_board(struct b
 	bcm43xx_pctl_set_crystal(bcm, 0);
 
 	/* Set the MAC address in the networking subsystem */
-	if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_A)
+	if (is_valid_ether_addr(bcm->sprom.et1macaddr))
 		memcpy(bcm->net_dev->dev_addr, bcm->sprom.et1macaddr, 6);
 	else
 		memcpy(bcm->net_dev->dev_addr, bcm->sprom.il0macaddr, 6);


--
Ciao
Stefano
