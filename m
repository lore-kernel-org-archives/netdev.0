From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 4/5] net: phy: Use phy name when requesting the interrupt
Date: Sun, 16 Oct 2016 19:56:52 +0200
Message-ID: <1476640613-25365-5-git-send-email-andrew@lunn.ch>
References: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46328 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755789AbcJPR6R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 13:58:17 -0400
In-Reply-To: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the fixed name "phy_interrupt" is not very informative in
/proc/interrupts when there are a lot of phys, e.g. a device with an
Ethernet switch. So when requesting the interrupt, use the name of the
phy.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index bb673c63c85c..96bf03352bb8 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -736,8 +736,7 @@ int phy_start_interrupts(struct phy_device *phydev)
 	atomic_set(&phydev->irq_disable, 0);
 	if (request_threaded_irq(phydev->irq, NULL, phy_interrupt,
 				 IRQF_ONESHOT | IRQF_SHARED,
-				 "phy_interrupt",
-				 phydev) < 0) {
+				 phydev_name(phydev), phydev) < 0) {
 		pr_warn("%s: Can't get IRQ %d (PHY)\n",
 			phydev->mdio.bus->name, phydev->irq);
 		phydev->irq = PHY_POLL;
-- 
2.9.3
