From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [PATCH] bcm43xx: check for valid MAC address in SPROM
Date: Fri, 5 May 2006 01:26:29 +0200
Message-ID: <20060505012629.14f38928@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.polimi.it ([131.175.12.3]:13452 "EHLO polimi.it")
	by vger.kernel.org with ESMTP id S932432AbWEDX13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 19:27:29 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please apply to 2.6.17, as it fixes a problem that prevents bcm43xx devices
which support 802.11a in addition to 802.11b/g from working, as the MAC
address isn't detected correctly. This applies to 2.6.17-rc3.

--

Check for valid MAC address in SPROM fields instead of relying on PHY type
while setting the MAC address in the networking subsystem, as some devices
have multiple PHYs.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 00:50:00.370034536 +0200
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 00:50:03.926493872 +0200
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
