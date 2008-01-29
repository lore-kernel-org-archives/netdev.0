From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH 1/1 resend][arm/at91_ether.c]  logical/bitand typo in function
 reset_phy() (inactive), drivers/net/arm/at91_ether.c
Date: Tue, 29 Jan 2008 21:14:56 +0100
Message-ID: <479F8940.7030301@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: andrew@sanpeople.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:56605 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934401AbYA2UPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 15:15:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

include/linux/mii.h:48:#define BMCR_RESET 0x8000

The function reset_phy() is in "#if 0" inactivated code
--
Replace logical "&&" by bit "&" before BMCR_RESET

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 25b114a..0ae0d83 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -384,7 +384,7 @@ static void reset_phy(struct net_device *dev)
 	/* Wait until PHY reset is complete */
 	do {
 		read_phy(lp->phy_address, MII_BMCR, &bmcr);
-	} while (!(bmcr && BMCR_RESET));
+	} while (!(bmcr & BMCR_RESET));
 
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);

