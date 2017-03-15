From: Roger Quadros <rogerq@ti.com>
Subject: [RFC PATCH] net: phy: Don't miss phy_suspend() on PHY_HALTED for PHYs with interrupts
Date: Wed, 15 Mar 2017 15:51:27 +0200
Message-ID: <1489585887-8683-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <kyle.roeschley@ni.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Roger Quadros <rogerq@ti.com>
To: <f.fainelli@gmail.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
phy_suspend() doesn't get called as part of phy_stop() for PHYs using
interrupts because the phy state machine is never triggered after a phy_stop().

Explicitly trigger the PHY state machine so that it can
see the new PHY state (HALTED) and suspend the PHY.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/phy/phy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 1be69d8..8fef03b 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -903,6 +903,7 @@ void phy_stop(struct phy_device *phydev)
 	 * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
 	 * will not reenable interrupts.
 	 */
+	phy_trigger_machine(phydev, true);
 }
 EXPORT_SYMBOL(phy_stop);
 
-- 
2.7.4
