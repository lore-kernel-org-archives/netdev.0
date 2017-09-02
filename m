From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: loop: Do not unregister invalid fixed PHY
Date: Sat,  2 Sep 2017 08:56:45 -0700
Message-ID: <20170902155645.19071-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During error injection it was possible to crash in dsa_loop_exit() because of
an attempt to unregister an invalid PHY. We actually want to the driver probing
in dsa_loop_init() even though fixed_phy_register() may return an error to
exercise how DSA deals with such cases, but we should not be crashing during
driver removal.

Fixes: 98cd1552ea27 ("net: dsa: Mock-up driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/dsa_loop.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index fdd8f3872102..8150e3a3c8dd 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -390,7 +390,7 @@ static void __exit dsa_loop_exit(void)
 
 	mdio_driver_unregister(&dsa_loop_drv);
 	for (i = 0; i < NUM_FIXED_PHYS; i++)
-		if (phydevs[i])
+		if (!IS_ERR(phydevs[i]))
 			fixed_phy_unregister(phydevs[i]);
 }
 module_exit(dsa_loop_exit);
-- 
2.11.0
