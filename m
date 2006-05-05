From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [PATCH 1/3] bcm43xx-d80211: check for valid MAC address in SPROM
Date: Fri, 5 May 2006 21:55:42 +0200
Message-ID: <20060505215542.25d310dd@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.polimi.it ([131.175.12.3]:38359 "EHLO polimi.it")
	by vger.kernel.org with ESMTP id S1751028AbWEET4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 15:56:17 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please apply to wireless-dev.

--

Check for valid MAC address in SPROM fields instead of relying on PHY type
while setting the MAC address in the networking subsystem, as some devices
have multiple PHYs.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 00:50:00.370034536 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 02:43:44.981535888 +0200
@@ -3482,7 +3482,7 @@
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
