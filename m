From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH v2] Revert "phy: IRQ cannot be shared"
Date: Wed, 24 Aug 2016 16:47:53 -0500
Message-ID: <1472075273-16257-1-git-send-email-xander.huff@ni.com>
References: <e2248086-6087-0fcd-1338-8f6463943c62@cogentembedded.com>
Cc: netdev@vger.kernel.org, brad.mouring@ni.com,
        Xander Huff <xander.huff@ni.com>, linux-kernel@vger.kernel.org,
        Nathan Sullivan <nathan.sullivan@ni.com>
To: f.fainelli@gmail.com, sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e2248086-6087-0fcd-1338-8f6463943c62@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts:
  commit 33c133cc7598 ("phy: IRQ cannot be shared")

On hardware with multiple PHY devices hooked up to the same IRQ line, allow
them to share it.

Sergei Shtylyov says:
  "I'm not sure now what was the reason I concluded that the IRQ sharing
  was impossible... most probably I thought that the kernel IRQ handling
  code exited the loop over the IRQ actions once IRQ_HANDLED was returned
  -- which is obviously not so in reality..."

Signed-off-by: Xander Huff <xander.huff@ni.com>
Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
Note: this reverted code fails "CHECK: Alignment should match open
parentesis"
---
 drivers/net/phy/phy.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c5dc2c36..c6f6683 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -722,8 +722,10 @@ phy_err:
 int phy_start_interrupts(struct phy_device *phydev)
 {
 	atomic_set(&phydev->irq_disable, 0);
-	if (request_irq(phydev->irq, phy_interrupt, 0, "phy_interrupt",
-			phydev) < 0) {
+	if (request_irq(phydev->irq, phy_interrupt,
+				IRQF_SHARED,
+				"phy_interrupt",
+				phydev) < 0) {
 		pr_warn("%s: Can't get IRQ %d (PHY)\n",
 			phydev->mdio.bus->name, phydev->irq);
 		phydev->irq = PHY_POLL;
-- 
1.9.1
