From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH] phy: request shared IRQ
Date: Wed, 24 Aug 2016 12:53:36 -0500
Message-ID: <1472061216-11111-1-git-send-email-xander.huff@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        brad.mouring@ni.com, Nathan Sullivan <nathan.sullivan@ni.com>,
        xander.huff@ni.com
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Sullivan <nathan.sullivan@ni.com>

On hardware with multiple PHY devices hooked up to the same IRQ line, allow
them to share it.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
Signed-off-by: Xander Huff <xander.huff@ni.com>
Acked-by: Ben Shelton <ben.shelton@ni.com>
Acked-by: Jaeden Amero <jaeden.amero@ni.com>
---
 drivers/net/phy/phy.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c5dc2c36..0050531 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -722,8 +722,8 @@ phy_err:
 int phy_start_interrupts(struct phy_device *phydev)
 {
 	atomic_set(&phydev->irq_disable, 0);
-	if (request_irq(phydev->irq, phy_interrupt, 0, "phy_interrupt",
-			phydev) < 0) {
+	if (request_irq(phydev->irq, phy_interrupt, IRQF_SHARED,
+			"phy_interrupt", phydev) < 0) {
 		pr_warn("%s: Can't get IRQ %d (PHY)\n",
 			phydev->mdio.bus->name, phydev->irq);
 		phydev->irq = PHY_POLL;
-- 
1.9.1
