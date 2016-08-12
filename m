From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: phy: initialize rc to zero to avoid returning garbage value
Date: Fri, 12 Aug 2016 21:29:24 +0100
Message-ID: <1471033764-7077-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

In the case where phydev->interrupts is not PHY_INTERRUPT_ENABLED
function vsc85xx_ack_interrupt is returning an uninitialized
garbage value.  Fix this by initializing rc to zero.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/phy/mscc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 2e1de53..ad33390 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -84,7 +84,7 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 
 static int vsc85xx_ack_interrupt(struct phy_device *phydev)
 {
-       int rc;
+       int rc = 0;
 
        if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
                rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
-- 
2.8.1
