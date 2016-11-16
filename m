From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 3/3] net: phy: fixed_phy: fix of_node leak in fixed_phy_unregister
Date: Wed, 16 Nov 2016 15:20:38 +0100
Message-ID: <1479306038-27211-4-git-send-email-johan@kernel.org>
References: <1479306038-27211-1-git-send-email-johan@kernel.org>
Cc: Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479306038-27211-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the of_node reference taken in fixed_phy_register()
when deregistering a PHY.

Fixes: a75951217472 ("net: phy: extend fixed driver with
fixed_phy_register()")

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/fixed_phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index c649c101bbab..eb5167210681 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -279,7 +279,7 @@ EXPORT_SYMBOL_GPL(fixed_phy_register);
 void fixed_phy_unregister(struct phy_device *phy)
 {
 	phy_device_remove(phy);
-
+	of_node_put(phy->mdio.dev.of_node);
 	fixed_phy_del(phy->mdio.addr);
 }
 EXPORT_SYMBOL_GPL(fixed_phy_unregister);
-- 
2.7.3
