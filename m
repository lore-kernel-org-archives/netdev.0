From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] net: phy: Fix truncation of large IRQ numbers in phy_attached_print()
Date: Thu, 21 Sep 2017 13:27:02 +0200
Message-ID: <1505993222-16721-1-git-send-email-geert+renesas@glider.be>
Cc: Romain Perier <romain.perier@collabora.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baptiste.telenet-ops.be ([195.130.132.51]:53978 "EHLO
        baptiste.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbdIUL1G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 07:27:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given NR_IRQS is 2048 on sparc64, and even 32784 on alpha, 3 digits is
not enough to represent interrupt numbers on all architectures.  Hence
PHY interrupt numbers may be truncated during printing.

Increase the buffer size from 4 to 8 bytes to fix this.

Fixes: 5e369aefdce4818c ("net: stmmac: Delete dead code for MDIO registration")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 drivers/net/phy/phy_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 8cf0c5901f95870f..67f25ac29025c539 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -879,7 +879,7 @@ void phy_attached_print(struct phy_device *phydev, const char *fmt, ...)
 {
 	const char *drv_name = phydev->drv ? phydev->drv->name : "unbound";
 	char *irq_str;
-	char irq_num[4];
+	char irq_num[8];
 
 	switch(phydev->irq) {
 	case PHY_POLL:
-- 
2.7.4
