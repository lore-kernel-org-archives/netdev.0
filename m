From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 4/6] net: phy: Use phy name when requesting the interrupt
Date: Wed, 28 Sep 2016 10:32:22 +0200
Message-ID: <1475051544-18561-5-git-send-email-andrew@lunn.ch>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34939 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751892AbcI1IeH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 04:34:07 -0400
In-Reply-To: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the fixed name "phy_interrupt" is not very informative in
/proc/interrupts when there are a lot of phys, e.g. a device with an
Ethernet switch. So when requesting the interrupt, use the name of the
phy.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 09fa8a950af1..940450c6cd2c 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -718,7 +718,7 @@ int phy_start_interrupts(struct phy_device *phydev)
 {
 	atomic_set(&phydev->irq_disable, 0);
 	if (request_threaded_irq(phydev->irq, NULL, phy_interrupt,
-				 IRQF_ONESHOT, "phy_interrupt",
+				 IRQF_ONESHOT, phydev_name(phydev),
 				 phydev) < 0) {
 		pr_warn("%s: Can't get IRQ %d (PHY)\n",
 			phydev->mdio.bus->name, phydev->irq);
-- 
2.9.3
