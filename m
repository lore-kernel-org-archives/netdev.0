From: Mark Salter <msalter@redhat.com>
Subject: [PATCH] net: phy: export fixed_phy_register()
Date: Thu, 11 Dec 2014 23:03:26 -0500
Message-ID: <1418357006-2450-1-git-send-email-msalter@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Mark Salter <msalter@redhat.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When building the bcmgenet driver as module, I get:

ERROR: "fixed_phy_register" [drivers/net/ethernet/broadcom/genet/genet.ko] undefined!

commit b0ba512e225d72 ("net: bcmgenet: enable driver to work without device
tree") which added a call to fixed_phy_register. But fixed_phy_register
needs to be exported if used from a module.

Signed-off-by: Mark Salter <msalter@redhat.com>
---
 drivers/net/phy/fixed.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 47872caa..3ad0e6e 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -274,6 +274,7 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 
 	return phy;
 }
+EXPORT_SYMBOL_GPL(fixed_phy_register);
 
 static int __init fixed_mdio_bus_init(void)
 {
-- 
1.8.3.1
