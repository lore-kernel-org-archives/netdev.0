From: Zach Brown <zach.brown@ni.com>
Subject: [PATCH] net: phy: handle state correctly in phy_stop_machine
Date: Wed, 22 Mar 2017 15:27:01 -0500
Message-ID: <1490214421-7269-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Sullivan <nathan.sullivan@ni.com>

If the PHY is halted on stop, then do not set the state to PHY_UP.  This
ensures the phy will be restarted later in phy_start when the machine is
started again.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
Signed-off-by: Brad Mouring <brad.mouring@ni.com>
Acked-by: Xander Huff <xander.huff@ni.com>
Acked-by: Kyle Roeschley <kyle.roeschley@ni.com>
---
 drivers/net/phy/phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7cc1b7d..fe2d4c4 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -678,7 +678,7 @@ void phy_stop_machine(struct phy_device *phydev)
 	cancel_delayed_work_sync(&phydev->state_queue);
 
 	mutex_lock(&phydev->lock);
-	if (phydev->state > PHY_UP)
+	if (phydev->state > PHY_UP && phydev->state != PHY_HALTED)
 		phydev->state = PHY_UP;
 	mutex_unlock(&phydev->lock);
 }
-- 
2.7.4
